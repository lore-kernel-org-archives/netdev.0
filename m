From: Smart Weblications GmbH - Florian Wiessner
	<f.wiessner@smart-weblications.de>
Subject: Re: 3.12.33 Bug with ipvs
Date: Wed, 26 Nov 2014 23:38:41 +0100
Message-ID: <54765671.5000704@smart-weblications.de>
References: <54763E3F.4020306@smart-weblications.de>
Reply-To: f.wiessner@smart-weblications.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smart-weblications.de ([188.65.144.61]:37479 "EHLO
	mail.smart-weblications.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753314AbaKZWiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 17:38:54 -0500
Received: from office.smart-weblications.net (unknown [91.204.168.193])
	by mail.smart-weblications.de (Postfix) with ESMTPA id E5F824057C5
	for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 22:38:50 +0000 (UTC)
Received: from [192.168.200.60] (unknown [192.168.200.60])
	by office.smart-weblications.net (Postfix) with ESMTPA id 917B6C0D47
	for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 23:38:50 +0100 (CET)
In-Reply-To: <54763E3F.4020306@smart-weblications.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 26.11.2014 21:55, schrieb Smart Weblications GmbH - Florian Wiessner=
:

>=20
> I can't get a clue of that output. I rebuild the kernel now with
>=20
> CONFIG_IP_VS=3Dm
> # CONFIG_IP_VS_IPV6 is not set
> # CONFIG_IP_VS_DEBUG is not set
> CONFIG_IP_VS_TAB_BITS=3D18
> CONFIG_IP_VS_PROTO_TCP=3Dy
> CONFIG_IP_VS_PROTO_UDP=3Dy
> # CONFIG_IP_VS_PROTO_AH_ESP is not set
> # CONFIG_IP_VS_PROTO_ESP is not set
> # CONFIG_IP_VS_PROTO_AH is not set
> # CONFIG_IP_VS_PROTO_SCTP is not set
> CONFIG_IP_VS_RR=3Dm
> CONFIG_IP_VS_WRR=3Dm
> CONFIG_IP_VS_LC=3Dm
> CONFIG_IP_VS_WLC=3Dm
> CONFIG_IP_VS_LBLC=3Dm
> CONFIG_IP_VS_LBLCR=3Dm
> CONFIG_IP_VS_DH=3Dm
> CONFIG_IP_VS_SH=3Dm
> CONFIG_IP_VS_SED=3Dm
> CONFIG_IP_VS_NQ=3Dm
> CONFIG_IP_VS_SH_TAB_BITS=3D12
> CONFIG_IP_VS_FTP=3Dm
> CONFIG_IP_VS_NFCT=3Dy
> CONFIG_IP_VS_PE_SIP=3Dm
>=20

Unfortunatelly the problem still exists even when IP_VS_IPV6 disabled.


--=20

Mit freundlichen Gr=FC=DFen,

=46lorian Wiessner

Smart Weblications GmbH
Martinsberger Str. 1
D-95119 Naila

fon.: +49 9282 9638 200
fax.: +49 9282 9638 205
24/7: +49 900 144 000 00 - 0,99 EUR/Min*
http://www.smart-weblications.de

--
Sitz der Gesellschaft: Naila
Gesch=E4ftsf=FChrer: Florian Wiessner
HRB-Nr.: HRB 3840 Amtsgericht Hof
*aus dem dt. Festnetz, ggf. abweichende Preise aus dem Mobilfunknetz
