From: "ASIX Allan Email [office]" <allan@asix.com.tw>
Subject: RE: [PATCH 0/4] Add a driver for the ASIX AX88172A
Date: Tue, 10 Jul 2012 10:20:21 +0800
Message-ID: <000001cd5e42$93d6c1f0$bb8445d0$@com.tw>
References: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at> <CANEJEGuiw7w0aV47AnRQGzqBNCyAb7jj9t+Dh2XbzwMtV=doWw@mail.gmail.com> <4FFB5AC6.3000506@teksavvy.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: "'Christian Riesch'" <christian.riesch@omicron.at>,
	<netdev@vger.kernel.org>, "'Oliver Neukum'" <oneukum@suse.de>,
	"'Eric Dumazet'" <edumazet@google.com>,
	"'Ming Lei'" <tom.leiming@gmail.com>,
	"'Michael Riesch'" <michael@riesch.at>
To: "'Mark Lord'" <kernel@teksavvy.com>,
	"'Grant Grundler'" <grundler@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from asix.com.tw ([113.196.140.82]:56372 "EHLO asix.com.tw"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752890Ab2GJCUh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 22:20:37 -0400
In-Reply-To: <4FFB5AC6.3000506@teksavvy.com>
Content-Language: zh-tw
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear All,

>From ASIX support viewpoint, it might be hard to support all AX88172A target applications on Linux kernel native ax88172a.c driver because some of AX88172A applications are embedded on customers' special target applications such as the AX88172A (PHY mode or Dual-PHY mode) + external MAC controller on-board design applications. For these kinds of AX88172A applications, the AX88172A Linux driver was qualified in our customers' site directly. It means ASIX doesn't have those customers' AX88172A devices in our site for testing. 

But for some AX88172A target applications such as AX88172A + external Fiber PHY and AX88172A + external National DP83640 PHY (Christian is testing under), etc. USB dongle applications, it is possible to support them on Linux kernel native ax88172a.c driver but *** the readme of this driver source might need to indicate clearly what kinds of AX88172A devices had been verified on this ax88172a.c native driver source ***. It will avoid users were confusing why their AX88172A devices couldn't work fine on Linux kernel native driver in future. 

Please let us know if you need more information. Thanks a lot. 


---
Best regards,
Allan Chou
Technical Support Division
ASIX Electronics Corporation
TEL: 886-3-5799500 ext.228
FAX: 886-3-5799558
E-mail: allan@asix.com.tw 
http://www.asix.com.tw/ 

-----Original Message-----
From: Mark Lord [mailto:kernel@teksavvy.com] 
Sent: Tuesday, July 10, 2012 6:27 AM
To: Grant Grundler
Cc: Christian Riesch; netdev@vger.kernel.org; Oliver Neukum; Eric Dumazet; Allan Chou; Ming Lei; Michael Riesch
Subject: Re: [PATCH 0/4] Add a driver for the ASIX AX88172A

On 12-07-09 01:45 PM, Grant Grundler wrote:
> Christian,
> Here's my $0.02 response to your questions.
> 
> On Fri, Jul 6, 2012 at 4:33 AM, Christian Riesch
> <christian.riesch@omicron.at> wrote:
> ...
>> I have a few questions:
>>
>> 1) Is it ok to factor out the common code like I did? Or should
>>    it go into a separate kernel module?
> 
> I think it's ok. I'd rather not see additional kernel modules unless
> the driver is substantially different.

I'll second that.  Ideally, somebody should pick up the pieces
from my aborted efforts last fall, and just get the real ASIX driver
itself tidied and into the kernel.  Then *everything* would work.

But I doubt that would be feasible at this point.

Cheers
