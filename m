From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] NET: cdc-phonet, handle empty phonet header
Date: Mon, 14 Mar 2011 15:24:29 -0700 (PDT)
Message-ID: <20110314.152429.191392418.davem@davemloft.net>
References: <1300035271-8138-1-git-send-email-jslaby@suse.cz>
	<1300035271-8138-2-git-send-email-jslaby@suse.cz>
	<201103140949.04760.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jslaby@suse.cz, jirislaby@gmail.com, netdev@vger.kernel.org,
	gregkh@suse.de, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201103140949.04760.remi.denis-courmont@nokia.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "R=E9mi Denis-Courmont" <remi.denis-courmont@nokia.com>
Date: Mon, 14 Mar 2011 09:49:04 +0200

> On Sunday 13 March 2011 18:54:31 ext Jiri Slaby, you wrote:
>> Currently, for N 5800 XM I get:
>> cdc_phonet: probe of 1-6:1.10 failed with error -22
>>=20
>> It's because phonet_header is empty. Extra altsetting looks like
>> there:
>> E 05 24 00 01 10 03 24 ab 05 24 06 0a 0b 04 24 fd  .$....$..$....$.
>> E 00                                               .
>>=20
>> I don't see the header used anywhere so just check if the phonet
>> descriptor is there, not the structure itself.
>>=20
>> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
>> Cc: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>> Cc: David S. Miller <davem@davemloft.net>
>=20
> Acked-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Also applied, thanks.
