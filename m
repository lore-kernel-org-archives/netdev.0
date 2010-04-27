From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Tue, 27 Apr 2010 21:31:00 +0300
Message-ID: <1272393060.30392.2.camel@lb-tlvb-eilong.il.broadcom.com>
References: <4BD5F553.6020006@hp.com>
 <20100426.134051.232750473.davem@davemloft.net>
 <4BD5FC16.4070402@hp.com>
 <20100426.135305.15235166.davem@davemloft.net>
 <4BD601C3.5030108@hp.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rick Jones" <rick.jones2@hp.com>,
	"David Miller" <davem@davemloft.net>,
	"therbert@google.com" <therbert@google.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4111 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752689Ab0D0SbL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 14:31:11 -0400
In-Reply-To: <4BD601C3.5030108@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-04-26 at 14:12 -0700, Rick Jones wrote:
> David Miller wrote:
> > From: Rick Jones <rick.jones2@hp.com>
> > Date: Mon, 26 Apr 2010 13:48:22 -0700
> > 
> >>Do not confuse explanation with endorsement.
> > 
> > Ok, fair enough.
> > 
> > But I don't see even the "other perspective" argument being even
> > valid.  Big shops still use UDP and it has to scale.
> 
> Preface - I too think it is massively stupid to ignore anything but TCP/IPv4, 
> and unwise to ignore IPv6 and so on, but there is a very real reason why one of 
> my email signatures reads:
> 
> "The road to hell is paved with business decisions"
> 
> > Or have they made multicast magically start working with TCP so
> > they can us it to do trades on the NASDAQ?
> 
> No. How many NIC chips can NASDAQ be expected to move? 0.1%? or even 1% of the 
> NIC chip market?
> 
> How many more NIC chips are in places where someone says "You sold me on 
> iSCSI/FCoE/whatnot, why can't I get 'link-rate'  to/from iSCSI storage/whatnot?!"
> 
> The NIC designer is there with his finance guys breathing down his neck shouting 
> "ROI Uber Alles!" and "Your budget is only this many monetary units!"  The 
> system designers at the system vendors are hearing the same things from their 
> own finance guys, have certain schedules, which then has them going to the NIC 
> firms, who want to sell chips to the system guys "You have to be ready to ship 
> by this date and your chip has to sell for no more than this."
> 
> Lather, rinse, repeat a few times and you get compromises on top of compromises.
> 
> Sometimes I think it is a wonder any of it actually works at all...
> 
> rick jones

Though the thread is going in a different direction now, I just wanted
to clarify two things:
- yes, the 57710 and 57711 only handle the IP (src+dst) for UDP toeplitz
hash. We all agree that it is much better to address the UDP ports as
well, but I think Rick Jones explained the process very well - thank you
Rick. Just to add one more (lame) excuse: the HW was designed before new
NAPI was introduced and it complies with the requirements from Redmond
- the next generation (57712) which we already sample does (finally)
support it. We are working on a patch series to enhance the bnx2x to
support this device now.

Eilon



