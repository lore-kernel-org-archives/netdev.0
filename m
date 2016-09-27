From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: Re: [RFC PATCH net-next 2/2] sfc: report 4-tuple UDP hashing to
 ethtool, if it's enabled
Date: Tue, 27 Sep 2016 18:12:13 +0000
Message-ID: <BL2PR07MB23067E952300940F9D8FDE108DCC0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <cc07d60a-189c-8475-ecb3-b612ff13bd5a@solarflare.com>,<8341c601-674a-74ff-c6dd-689c19b3ce7f@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "bkenward@solarflare.com" <bkenward@solarflare.com>
To: Edward Cree <ecree@solarflare.com>,
        "linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0070.outbound.protection.outlook.com ([104.47.32.70]:20736
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S934935AbcI0SMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Sep 2016 14:12:25 -0400
In-Reply-To: <8341c601-674a-74ff-c6dd-689c19b3ce7f@solarflare.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 info->data =3D 0;
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 switch (info->flow_type)=
 {
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 case UDP_V4_FLOW:
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (e=
fx->rx_hash_udp_4tuple)
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 /* fall through */
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 /* el=
se fall further! */
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 case TCP_V4_FLOW:
> -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 info-=
>data |=3D RXH_L4_B_0_1 | RXH_L4_B_2_3;
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 info->data |=3D RXH_L4_B_0_1 | RXH_L4_B_2_3;
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =
/* fall through */
> -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 case UDP_V4_FLOW:
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 case SCTP_V4_FLOW:
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 case AH_ESP_V4_FLOW:
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 case IPV4_FLOW:
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =
info->data |=3D RXH_IP_SRC | RXH_IP_DST;
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =
min_revision =3D EFX_REV_FALCON_B0;
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =
break;

Well, you sure fulfilled your cover letter's promise. ;-)

Do you really prefer this conditional mayham over copy-pasting some lines?=
