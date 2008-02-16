From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: RESEND, HTB(?) softlockup, vanilla 2.6.24
Date: Sat, 16 Feb 2008 21:45:19 +0100
Message-ID: <20080216204519.GA2739@ami.dom.local>
References: <20080213081318.M90354@visp.net.lb> <47B69824.4030405@gmail.com> <20080216102502.M41110@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:59918 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756411AbYBPUmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2008 15:42:23 -0500
Received: by ug-out-1314.google.com with SMTP id z38so81481ugc.16
        for <netdev@vger.kernel.org>; Sat, 16 Feb 2008 12:42:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080216102502.M41110@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 16, 2008 at 12:25:31PM +0200, Denys Fedoryshchenko wrote:
> Thanks, i will try it.
> You think lockdep can be buggy?

Just like every code... But the main reason is it has quite meaningful
overhead, so could be right "in production" only after lockups happen.
But if it doesn't report anything anyway...

Your report shows there are quite long paths of calls during softirqs
with some actions (ipt + mirred here?) and qdiscs, so if I'm not wrong
with this stack problem, this would need some optimization. And, of
course, there could be some additional bugs involved around too:
otherwise it seems this should happen more often. But I don't expect
you would try to debug this on your servers, so I hope, it simply will
be found BTW some day... 

Regards,
Jarek P.
