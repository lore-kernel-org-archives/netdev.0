From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH 3/5] bgmac: add support for new BGMAC_CMDCFG_SR position
 on core rev >= 4
Date: Thu, 2 Jan 2014 21:28:31 +0100
Message-ID: <CACna6rz56gCNaTnvh1Dig=Dk8mE-=xK2gWuUoOMxiyUWowwXVA@mail.gmail.com>
References: <1388690342-27213-1-git-send-email-hauke@hauke-m.de>
	<1388690342-27213-3-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:34966 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752012AbaABU2c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 15:28:32 -0500
Received: by mail-ob0-f174.google.com with SMTP id wn1so14888962obc.33
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 12:28:31 -0800 (PST)
In-Reply-To: <1388690342-27213-3-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014/1/2 Hauke Mehrtens <hauke@hauke-m.de>:
> The BGMAC_CMDCFG_SR register is at a different position on core rev >=
=3D 4
> -#define  BGMAC_CMDCFG_SR                       0x00000800      /* Se=
t to reset mode */
> +#define  BGMAC_CMDCFG_SR_REVO                  0x00000800      /* Se=
t to reset mode, for other revs */
> +#define  BGMAC_CMDCFG_SR_REV4                  0x00002000      /* Se=
t to reset mode, only for core rev 4 */
> +#define  BGMAC_CMDCFG_SR(rev)  ((rev >=3D 4) ? BGMAC_CMDCFG_SR_REV4 =
: BGMAC_CMDCFG_SR_REVO)

If you use _REV4 for rev 4+, then what about using _REV0 for rev 0+?

I guess REVO stands for OTHERS, but others doesn't actually mean rev !=3D=
 4 here.

Unless it was supposed to be 0 from the beginning and it's just a typo?

In future you may need to use _REV7 or whatever number.

--=20
Rafa=C5=82
