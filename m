From: Abraham Arce <abraham.arce.moreno@gmail.com>
Subject: Re: [RFC PATCH 0/2] ks8851: support for read/write MAC address from
	EEPROM
Date: Mon, 3 May 2010 21:13:46 -0500
Message-ID: <r2gcb8016981005031913xf7b1d0c7gff1229a3fc47133e@mail.gmail.com>
References: <1269886638-11025-1-git-send-email-s-jan@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ben Dooks <ben@simtec.co.uk>,
	Abraham Arce <x0066660@ti.com>
To: Sebastien Jan <s-jan@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:58797 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755931Ab0EDCNs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 22:13:48 -0400
Received: by fxm10 with SMTP id 10so2752840fxm.19
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 19:13:46 -0700 (PDT)
In-Reply-To: <1269886638-11025-1-git-send-email-s-jan@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> I needed to program a mac address to the companion eeprom of our ks88=
51, and
> wrote the following patches, which use debug-fs as interface.
>
> I then realized that this seemed not the usual way to access net cont=
roller
> eeproms (ethtool seems the more standard way).
>
> I am very interesed in getting your feedbacks on the following:
> =A01) Does it make any sense to you to use this debug-fs interface to=
 read/write
> the mac address (advantage: no need for user to know how ks8851 manag=
es the
> eeprom / alignment / offset), and can it be upstreamed?
> =A02) Must a more generic eeprom access be implemented through ethtoo=
l (or another
> interface?)? Is it the only choice or can it coexist with option 1)? =
(most of
> code would be common)
> =A03) Any feedback regarding the code itself or anything else is very=
 welcome!
>

Does anyone could guide us about the implementation done by Sebastien?

http://patchwork.ozlabs.org/patch/48880/
http://patchwork.ozlabs.org/patch/48881/

Best Regards
Abraham
