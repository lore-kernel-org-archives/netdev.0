From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCHv2] net: Define enum for the bits used in features.
Date: Wed, 25 May 2011 11:48:47 +0200
Message-ID: <BANLkTikLkibK3qPMz1kyuRxg=_6rpecPjw@mail.gmail.com>
References: <1306263162-2022-1-git-send-email-maheshb@google.com>
 <1306288567-1773-1-git-send-email-maheshb@google.com> <BANLkTik4KYrR4vYm1R_hYNbwFjQ79FEoHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:33329 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754888Ab1EYJtI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 05:49:08 -0400
Received: by qwk3 with SMTP id 3so3797342qwk.19
        for <netdev@vger.kernel.org>; Wed, 25 May 2011 02:49:07 -0700 (PDT)
In-Reply-To: <BANLkTik4KYrR4vYm1R_hYNbwFjQ79FEoHQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 25 maja 2011 11:43 u=BFytkownik Micha=B3 Miros=B3aw <mirqus@gmai=
l.com> napisa=B3:
[...]
> And here GSO aliases:
>
> TSO_BIT =3D NETIF_F_GSO_SHIFT + SKB_GSO_TCPV4,
> UFO_BIT =3D NETIF_F_GSO_SHIFT + SKB_GSO_UDP,

Ah, this is wrong as SKB_GSO_* are bitmasks. Can be fixed though.

Best Regards,
Micha=B3 Miros=B3aw
