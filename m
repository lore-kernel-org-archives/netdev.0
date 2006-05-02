From: Nuri Jawad <lkml@jawad.org>
Subject: Re: Fw: Bug: PPP dropouts in >=2.6.16
Date: Tue, 2 May 2006 22:55:17 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0605022233180.21275@pc>
References: <20060430114356.GA9810@ats.dyn.bawue.de> <Pine.LNX.4.64.0604301520030.5512@pc>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from leitseite.net ([213.239.214.51]:44006 "EHLO mail.leitseite.net")
	by vger.kernel.org with ESMTP id S964887AbWEBUze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 May 2006 16:55:34 -0400
To: netdev@vger.kernel.org
In-Reply-To: <Pine.LNX.4.64.0604301520030.5512@pc>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Good evening,

Bugzilla entry on this is now here:
http://bugzilla.kernel.org/show_bug.cgi?id=6484

Note the interesting fact that kernel mode PPPoE is not affected. Thus it 
could also be a bug in Roaring Penguin's PPPoE program. The problem is 
that all other user space implementations seem to be quite outdated
(made for 2.2 kernels).

I still did observe around 500 packets being lost after a night of pinging 
this machine, compared to around 30 with 2.6.15.7 user mode pppoe and 
700-1100 with >=2.6.16 user mode. I made a little perl script that 
generates a histogram from ping's output and there were only single 
packets lost.
However, just when I was about to test kernel mode with 2.6.15.7 tonight, 
this effect disappeared. Might have been my ISP after all.

Thus, for the time being, kernel mode PPPoE seems to be a viable 
workaround.
The whole matter is a bit strange to me. I would have expected that the 
kernel only communicates with pppd which then utilizes a process 
encapsulating the packts in ethernet frames. That's why I didn't
think this bug was a pure pppoe issue, which it seems to be.

Regards, Nuri
