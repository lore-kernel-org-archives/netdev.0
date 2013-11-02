From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/24] cdc_ncm: many small and mostly trivial
 fixes
Date: Sat, 02 Nov 2013 02:02:57 -0400 (EDT)
Message-ID: <20131102.020257.1416912931673041539.davem@davemloft.net>
References: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	alexey.orishko@gmail.com
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33932 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770Ab3KBGDB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 02:03:01 -0400
In-Reply-To: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Fri,  1 Nov 2013 11:16:37 +0100

> This series ended up longer than expected, and it is still not
> complete. There is more to come when time allows...
>=20
> Most changes are trivial. Notable non-trivial changes are
>  - removed filtering of identical speed notifications
>  - tx_max calulation is changed to count the pad byte if
>    necessary, and respect the device limit as an absolute
>    upper limit even if it is too low according to the spec
>  - remove the bug preventing SET_MAX_DATAGRAM_SIZE from having
>    any effect
>  - drop the pad-to-max if ZLPs are enabled
>  - the driver specific VERSION is dropped
>  - dev->hard_mtu is set to tx_max instead of max_datagram_size
>    causing usbnet to calculate the qlen based on the real max
>    size of tx skbs
>=20
> This series has been tested, along with the previously posted
> cdc_mbim series, on the NCM and MBIM devices I have:
>  - Ericsson F5521gw (NCM)
>  - Huawei E367 (MBIM)
>  - D-Link DWM-156 A7 (MBIM w/ too low dwNtb{In,Out}MaxSize bug)
>  - Sierra Wireless MC7710 (MBIM w/ ZLP and CDC Union bugs)
>=20
> Apart from the D-Link modem dropping a lot less oversized
> frames with the fix dedicated to it, there are no end user
> noticable functional changes as a result of this series.  But
> all the non-trivial changes I listed above are of course
> detectable by users looking at that specific area (except maybe
> the removed speed notification, which requires a device sending
> duplicates to be noticable - I don't have any such device).

Looks good, series applied, thanks!
