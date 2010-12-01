From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 1/2] af_packet: use vmalloc_to_page() instead for the
 addresss returned by vmalloc()
Date: Wed, 1 Dec 2010 21:05:54 +0800
Message-ID: <AANLkTim7SSRMkhc_eMz+Bk12kAwfG==j-dH4NOPu-uS2@mail.gmail.com>
References: <1291125408-14389-1-git-send-email-xiaosuo@gmail.com>
 <1291126341.2904.82.camel@edumazet-laptop> <20101130143720.GA6017@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42035 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754182Ab0LANGP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 08:06:15 -0500
Received: by fxm20 with SMTP id 20so23066fxm.19
        for <netdev@vger.kernel.org>; Wed, 01 Dec 2010 05:06:14 -0800 (PST)
In-Reply-To: <20101130143720.GA6017@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 30, 2010 at 10:37 PM, Neil Horman <nhorman@tuxdriver.com> w=
rote:
> Off the top of my head, I would think that pgv_to_page could be proto=
typed such
> that it could accept addr, offset and struct page ** arguments. =A0Th=
at way we can
> track the current page that we're mapped to, lowering the number of c=
alls to
> vmalloc_to_page, and we can still use an increment like we do above (=
as long as
> its wrapped in a subsequent call to pgv_to_page)

I'll try to optimize pgv_to_page() after this patch series merged. I
am planning to call vmalloc_to_page() previously, and cache its result
in a per pgv array for future use. Thanks.


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
