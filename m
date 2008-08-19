From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Tue, 19 Aug 2008 14:28:49 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0808191425050.3324@nehalem.linux-foundation.org>
References: <alpine.LFD.1.10.0808190952000.3324@nehalem.linux-foundation.org> <alpine.LFD.1.10.0808191341150.3324@nehalem.linux-foundation.org> <20080819.140458.236030589.davem@davemloft.net> <200808192315.48718.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46748 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752811AbYHSV2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 17:28:55 -0400
In-Reply-To: <200808192315.48718.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 19 Aug 2008, Rafael J. Wysocki wrote:
> 
> FWIW, they fix the recent regression tracked as
> http://bugzilla.kernel.org/show_bug.cgi?id=11316 .

Yeah, and the real cause was apparently another commit that *ALSO* 
happened after the merge window!

Guys, you're making excuses for the problem.

The problem that triggered this bugus loopback change was commit 
e5a4a72d4f88f4389e9340d383ca67031d1b8536. Look at when that one was done. 

This is my whole _point_. The networking layer is doing development during 
the -rc window. And you guys are making excuses for it. Wake up, guys!

			Linus
