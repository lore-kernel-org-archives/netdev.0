From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Add useful per-connection TCP stats for diagnosis
 purpose.
Date: Mon, 21 Mar 2011 14:18:44 -0700
Message-ID: <20110321141844.25e96184@s6510>
References: <1300349189-2731-1-git-send-email-hkchu@google.com>
	<1300351330.10164.712.camel@edumazet-laptop>
	<AANLkTi=sLkXreC3LNsDuFDSeNMebr+ScMc12=gngd2cc@mail.gmail.com>
	<20110317142030.62af785a@nehalam>
	<AANLkTi=W-=8zhQpfJZ=DrDyUCwrT==5JkwRBiHaDkVXK@mail.gmail.com>
	<1300428324.2881.5.camel@edumazet-laptop>
	<AANLkTikrJ7A-ygc9JnkvfBpRaKjL0fKeta+9ASLDr0rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39674 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753646Ab1CUVSs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2011 17:18:48 -0400
In-Reply-To: <AANLkTikrJ7A-ygc9JnkvfBpRaKjL0fKeta+9ASLDr0rg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case it isn't clear. /proc/net/tcp is a legacy interface and any
changes to it are certain to be rejected. netlink stats are an extensible
interface and likely to be accepted.

