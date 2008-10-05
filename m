From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH to REVERT] Re: ax25 rose Re: kernel panic linux-2.6.27-rc7
Date: Mon, 6 Oct 2008 00:05:10 +0200
Message-ID: <20081005220510.GA2613@ami.dom.local>
References: <20081002194845.GB2664@ami.dom.local> <20081003073418.GA5235@ff.dom.local> <20081003074351.GB5235@ff.dom.local> <1223145027.23358.20.camel@f6bvp-5> <20081004191114.GA15152@ami.dom.local> <20081004200939.GB15152@ami.dom.local> <1223231469.18094.10.camel@f6bvp-5> <20081005204013.GB2526@ami.dom.local> <1223241500.18094.32.camel@f6bvp-5>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>
To: David Miller <davem@davemloft.net>,
	"Bernard, f6bvp" <f6bvp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:63515 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755053AbYJEWEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 18:04:25 -0400
Received: by ug-out-1314.google.com with SMTP id k3so1536642ugf.37
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2008 15:04:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1223241500.18094.32.camel@f6bvp-5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, please read below:
------------------------>

On Sun, Oct 05, 2008 at 11:18:20PM +0200, Bernard, f6bvp wrote:
> Jarek,
> 
> Yes, previous reports were without reverting David's patch.
> Now I have removed David's patch (ax25_std_timer.c) and reverted 9A4GL
> patch (af_ax25.c).
> Thus present kernel is the original plus 9A4GL patch plus your AX25_DBG
> and netrom patches and minus David's patch.
> The system has been stable for two hours and there is nothing special
> in /var/log/messages as can be seen the sample below.   

Great! So, I think we could agree with this:

1. Reverting this patch fixes the oops which started this thread:

	commit 30902dc3cb0ea1cfc7ac2b17bcf478ff98420d74
	Author: David S. Miller <davem@davemloft.net>
	Date:   Tue Jun 17 21:26:37 2008 -0700

	ax25: Fix std timer socket destroy handling.

2. Alternative (original) fix proposed by Tihomir Hidelberg:
	http://marc.info/?l=linux-netdev&m=121370472223572&w=2 
   doesn't seem to cause any problems.

David, please reconsider these changes as reported and tested
by Bernard.


Bernard, 
It looks like my netrom patch removes these unorphaned sockets from
this debugging log, so I'll resend this signed off soon.

Since now, please, treat these 1. & 2. above plus lib8390 & netrom
patches as a base for next tests, and if there are again any new
bugs from new tests, start new threads for them.

Thanks,
Jarek P.
