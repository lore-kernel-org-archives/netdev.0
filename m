From: Nuri Jawad <lkml@jawad.org>
Subject: Re: Fw: Bug: PPP dropouts in >=2.6.16
Date: Sun, 30 Apr 2006 16:10:25 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0604301520030.5512@pc>
References: <20060430114356.GA9810@ats.dyn.bawue.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <netdev-owner@vger.kernel.org>
Received: from leitseite.net ([213.239.214.51]:65245 "EHLO mail.leitseite.net")
	by vger.kernel.org with ESMTP id S1751125AbWD3OKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2006 10:10:47 -0400
Received: from pc ([10.1.0.2] helo=nj.yi.org)
	by mail.leitseite.net with esmtp (Exim 4.34)
	id 1FaCdC-0001g1-Ig
	for netdev@vger.kernel.org; Sun, 30 Apr 2006 16:10:38 +0200
Received: from localhost (localhost [127.0.0.1])
	by nj.yi.org (Postfix) with ESMTP id CA3181D889C
	for <netdev@vger.kernel.org>; Sun, 30 Apr 2006 16:10:25 +0200 (CEST)
To: netdev@vger.kernel.org
In-Reply-To: <20060430114356.GA9810@ats.dyn.bawue.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 30 Apr 2006, theosch@gmx.net wrote:

> I observed a 1-2 sec stalling behaviour for the complete system every
> 10 seconds or so _seemingly_ only when my ADSL connection was up.

I had that idea too, but that sounds different from what I have here. I 
have also transfered lots of data at >900 MBits/s with the e1000 and 
never had a single problem. The packets are not vanishing on the wire and 
the system does not stall, there's just nothing appearing on ppp0 tx at 
all. That sounds like an unrelated issue to me. 
BTW, there was no dropout in the last 8 hours, only after I started some 
tx load a while ago one of them came up within minutes.

> erroneous patch I realized I had changed the driver when upgrading the
> kernel to 2.6.14.

What does 2.6.14 have to do with it? The ppp problem appeared exactly with 
*2.6.16*. It looks like it will also be in 2.6.17 because nobody is 
stepping on the brake :/. All this with code that had worked perfectly 
fine for ages. I'm getting a bit frustrated here.

Well, I might try disabling the onboard e1000 and replacing it with a 
"good" old Realtek.

Regards, Nuri
