From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/2] adjust MTU as indicated by MBIM
 extended functional descriptor
Date: Thu, 20 Mar 2014 16:58:25 -0400 (EDT)
Message-ID: <20140320.165825.2258647784698720017.davem@davemloft.net>
References: <1395262806-19237-1-git-send-email-benchan@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, oliver@neukum.org,
	gregkh@linuxfoundation.org, bjorn@mork.no, gsuarez@smithmicro.com
To: benchan@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395262806-19237-1-git-send-email-benchan@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Ben Chan <benchan@chromium.org>
Date: Wed, 19 Mar 2014 14:00:04 -0700

> The MBIM extended functional descriptor, defined in "Universal Serial=
 Bus
> Communications Class Subclass Specification for Mobile Broadband Inte=
rface
> Model, Revision 1.0, Errata-1" by USB-IF, indicates the operator pref=
erred MTU
> value via a wMTU field.
>=20
> This patch set ensures that the initial MTU value set by cdc_ncm on a=
 MBIM net
> device does not exceed the wMTU value, provided the MBIM device expos=
es a MBIM
> extended functional descriptor.
>=20
> * Changelog
> v2: Fixed a le16_to_cpu conversion issue in patch 2/2 pointed out by
>     Bj=F8rn Mork <bjorn@mork.no>
> v3: No code changes. Resubmitted to include patch 1/2 as suggested by
>     David Miller <davem@davemloft.net>
> v4: No code changes. Resubmitted as suggested by David Miller:
>     - Added a summary of the patch set
>     - Carried the ACK from Greg Kroah-Hartman <gregkh@linuxfoundation=
=2Eorg>
>     - Added a specified the tree (net-next) to apply the patch set to

Series applied to net-next, thanks Ben.
