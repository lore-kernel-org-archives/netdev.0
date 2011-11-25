From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH net-next 1/2] netem: rate-latency extension
Date: Fri, 25 Nov 2011 13:02:18 +0100
Message-ID: <20111125120218.GB2810@hell>
References: <1322156378-23257-1-git-send-email-hagen@jauu.net>
 <1322172898.2872.7.camel@edumazet-laptop>
 <20111124210926.3e4b7567@s6510.linuxnetplumber.net>
 <1322201600.2872.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:50892 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754276Ab1KYMCU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 07:02:20 -0500
Content-Disposition: inline
In-Reply-To: <1322201600.2872.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet | 2011-11-25 07:13:20 [+0100]:

>Yes, but Hagen change adds a few lines to netem, and netem already
>handles throttling. This is why I believe its a nice enhancement.

We first modified TBF, but TBF address a slightly different task. So the patch
was a little bit awkward and complex (more awkward then the two additional
netem enqueue() lines). So in the end: yes, netem is the right place for this:
only a few lines in netem are required. Additionally: setup a qdisc chain with
TBF, netem, ... is also error prone. Students of mine repeatedly make mistakes
here. This change make a complete emulation setup even more easy. But this is
only a side note.

Hagen
