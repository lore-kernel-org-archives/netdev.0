From: Jason Liu <liu.h.jason@gmail.com>
Subject: Re: [PATCH 1/1] net/fec: add KSZ9021RN phy fixup
Date: Tue, 13 Dec 2011 10:29:53 +0800
Message-ID: <CAB4PhKfSegpwrZbedN7KtJd+xFk1JAOCWuSFq2you5dWn9bqwA@mail.gmail.com>
References: <1323684558-16796-1-git-send-email-richard.zhao@linaro.org>
	<CAOMZO5DNRrt7ULuBkh9y8bz2_fpCHOcSWxAbJOqTHA2Nrv1V_w@mail.gmail.com>
	<20111212135119.GE16835@b20223-02.ap.freescale.net>
	<4EE612BF.9050907@bluegiga.com>
	<20111213021008.GE28768@b20223-02.ap.freescale.net>
	<20111213023626.GA10866@S2100-06.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Richard Zhao <richard.zhao@freescale.com>, patches@linaro.org,
	netdev@vger.kernel.org, s.hauer@pengutronix.de, jgq516@gmail.com,
	eric.miao@linaro.org, Richard Zhao <richard.zhao@linaro.org>,
	Veli-Pekka Peltola <veli-pekka.peltola@bluegiga.com>,
	shawn.guo@linaro.org, Fabio Estevam <festevam@gmail.com>,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:47847 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753978Ab1LMC3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 21:29:53 -0500
Received: by iaeh11 with SMTP id h11so4045781iae.19
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2011 18:29:53 -0800 (PST)
In-Reply-To: <20111213023626.GA10866@S2100-06.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/12/13 Shawn Guo <shawn.guo@freescale.com>:
> On Tue, Dec 13, 2011 at 10:10:08AM +0800, Richard Zhao wrote:
>> By converting to DT, machine code's becoming common too. I feel hard to
>> find a place. Put it in imx6q_init_machine?
>>
>> Sascha & Shawn, Could you give comments here?
>>
> I see no problem to do that by checking board compatible string and
> do the setup for particular board.

Then, you may end up having more and more fix up in the fec driver
when all the platforms converted to DT,
which will put the fec driver into mess.

>
> --
> Regards,
> Shawn
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
