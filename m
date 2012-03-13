From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ip route show shows the routes in the inverse order?
Date: Tue, 13 Mar 2012 09:47:33 -0700
Message-ID: <1331657253.4449.2.camel@edumazet-glaptop>
References: <CAA7Uhc=xFxiAc9ZL0KHQJ1Opr0m=Do_OuLmL7WWd7PU4JuUNnQ@mail.gmail.com>
	 <20120312193204.5be5b4b8@nehalam.linuxnetplumber.net>
	 <20120313021529.97514922.billfink@mindspring.com>
	 <20120312.235234.73408595516828250.davem@davemloft.net>
	 <CAA7UhcmMYa+N4VUFjfM_qjCdhy3zAE0C8eN+Z0nsACNZeJ4RKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, billfink@mindspring.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Diego Woitasen <diego@woitasen.com.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:39273 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660Ab2CMQri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 12:47:38 -0400
Received: by ghrr11 with SMTP id r11so756718ghr.19
        for <netdev@vger.kernel.org>; Tue, 13 Mar 2012 09:47:38 -0700 (PDT)
In-Reply-To: <CAA7UhcmMYa+N4VUFjfM_qjCdhy3zAE0C8eN+Z0nsACNZeJ4RKA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-03-13 at 11:26 -0300, Diego Woitasen wrote:

> I don't aggree at this point. First, it was the behavior for years,
> like a "de facto" standard. Second, there a "natural ordering"  for
> routes. More specific match first, so it makes sense for them to be in
> the first place.

Please provide an iproute2 patch, this is not a kernel issue at all.

Keep in mind it might be very tricky, since a machine can have tons of
routes.
