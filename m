From: "Keyur Chudgar" <kchudgar.linux@gmail.com>
Subject: Fwd: skbuff data pointer alignment requirement
Date: Fri, 28 Dec 2007 16:54:23 -0800
Message-ID: <a967d7d00712281654i9de6b31if34a341fcd618e8a@mail.gmail.com>
References: <a967d7d00712201712m6981373ife9a333be7d343e0@mail.gmail.com>
	 <476CEE69.20902@gmail.com>
	 <a967d7d00712281653m5b1a937ch898a5b48f8ee1887@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.246]:15434 "EHLO
	hs-out-2122.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751579AbXL2AyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2007 19:54:25 -0500
Received: by hs-out-2122.google.com with SMTP id 54so2522899hsz.5
        for <netdev@vger.kernel.org>; Fri, 28 Dec 2007 16:54:23 -0800 (PST)
In-Reply-To: <a967d7d00712281653m5b1a937ch898a5b48f8ee1887@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---------- Forwarded message ----------
From: Keyur Chudgar <kchudgar.linux@gmail.com>
Date: Dec 28, 2007 4:53 PM
Subject: Re: skbuff data pointer alignment requirement
To: Jarek Poplawski <jarkao2@gmail.com>


Hi Jarek,

> Do you mean hardware requirements of an architecture or a specific driver?
I meant any hardware requirements of an architecture.

> So, if you have more than one network card, is it needed by all of them,
> while other (not network) drivers are happy with default allocations?
Yes. So, anything related to skbuff data block, will need specific alignment
requirements, while others (non-network drivers) will work as default.

Thanks,
- Keyur



On Dec 22, 2007 3:00 AM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> Keyur Chudgar wrote, On 12/21/2007 02:12 AM:
> ...
>
> > If some hardware requirements, for example is, they need to have 256
> > bytes aligned address for them to do the DMA, no matter what the
> > packet size is. In this kind of cases, can you guide me what should I
> > do? Is there any way already in Linux I can do this?
>
> ...
>
> > In the above specified situation, I can define SKB_ADDR_MIN_ALIGN =
> > 256 in my Makefile or I don't define it at all if I am okay with
> > default alignment size.
>
> Do you mean hardware requirements of an architecture or a specific driver?
> So, if you have more than one network card, is it needed by all of them,
> while other (not network) drivers are happy with default allocations?
>
> Regards,
> Jarek P.
>
