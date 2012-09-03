From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net: sierra_net: rx_urb_size is constant
Date: Mon, 03 Sep 2012 13:51:41 -0400 (EDT)
Message-ID: <20120903.135141.899178894779742228.davem@davemloft.net>
References: <1346664033-30284-1-git-send-email-bjorn@mork.no>
	<1346664033-30284-3-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49241 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755602Ab2ICRvn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2012 13:51:43 -0400
In-Reply-To: <1346664033-30284-3-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Mon,  3 Sep 2012 11:20:33 +0200

> The rx_urb_size is set to the same value for every device
> supported by this driver.  No need to keep a per-device
> data structure to do that. Replacing with a macro constant.
>=20
> This was the last device specific info, and removing it
> allows us to delete the sierra_net_info_data struct.
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied.
