From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: skbuff data pointer alignment requirement
Date: Sat, 22 Dec 2007 12:00:57 +0100
Message-ID: <476CEE69.20902@gmail.com>
References: <a967d7d00712201712m6981373ife9a333be7d343e0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Keyur Chudgar <kchudgar.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:42439 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbXLVK7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Dec 2007 05:59:06 -0500
Received: by ug-out-1314.google.com with SMTP id z38so768483ugc.16
        for <netdev@vger.kernel.org>; Sat, 22 Dec 2007 02:59:04 -0800 (PST)
In-Reply-To: <a967d7d00712201712m6981373ife9a333be7d343e0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Keyur Chudgar wrote, On 12/21/2007 02:12 AM:
...

> If some hardware requirements, for example is, they need to have 256
> bytes aligned address for them to do the DMA, no matter what the
> packet size is. In this kind of cases, can you guide me what should I
> do? Is there any way already in Linux I can do this?

...

> In the above specified situation, I can define SKB_ADDR_MIN_ALIGN =
> 256 in my Makefile or I don't define it at all if I am okay with
> default alignment size.

Do you mean hardware requirements of an architecture or a specific driver?
So, if you have more than one network card, is it needed by all of them,
while other (not network) drivers are happy with default allocations?

Regards,
Jarek P.
