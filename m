From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH] sh: sh_eth: Add support SH7734
Date: Fri, 23 Mar 2012 13:56:41 +0900
Message-ID: <4F6C0289.6080005@renesas.com>
References: <1332314014-31992-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <20120321.165818.1166540551487888245.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor2.renesas.com ([210.160.252.172]:44192 "EHLO
	relmlor2.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754977Ab2CWEuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 00:50:52 -0400
Received: from relmlir2.idc.renesas.com ([10.200.68.152])
 by relmlor2.idc.renesas.com ( SJSMS)
 with ESMTP id <0M1B006EVMSQCFC0@relmlor2.idc.renesas.com> for
 netdev@vger.kernel.org; Fri, 23 Mar 2012 13:50:50 +0900 (JST)
Received: from relmlac4.idc.renesas.com ([10.200.69.24])
 by relmlir2.idc.renesas.com ( SJSMS)
 with ESMTP id <0M1B00MLCMSQFHE0@relmlir2.idc.renesas.com> for
 netdev@vger.kernel.org; Fri, 23 Mar 2012 13:50:50 +0900 (JST)
In-reply-to: <20120321.165818.1166540551487888245.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller =E3=81=95=E3=82=93=E3=81=AF=E6=9B=B8=E3=81=8D=E3=81=BE=E3=81=
=97=E3=81=9F:
> From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> Date: Wed, 21 Mar 2012 16:13:34 +0900
>=20
>> Add define of SH7734 register and sh_eth_reset_hw_crc function.
>>
>> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
>=20
> This patch doesn't apply cleanly at all, also:
>=20
>> -#elif defined(CONFIG_CPU_SUBTYPE_SH7763)
>> +#elif defined(CONFIG_CPU_SUBTYPE_SH7734) ||\
>> +		defined(CONFIG_CPU_SUBTYPE_SH7763)
>=20
> This looks terrible, please don't split this line up like that.
>=20
> If you have to, at least put a space before the backslash at the end
> of the first line and make the "defined" on the second line match up,
> column wise, with the "defined" on the previous line.
>=20

OK, I will fix this.
Thank you.

Nobuhiro
