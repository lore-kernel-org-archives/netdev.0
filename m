From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] bgmac: omit the fcs
Date: Thu, 28 Feb 2013 18:57:03 +0100
Message-ID: <CACna6rw6MR3agrDvz0+X7ne6uSNQN0tpZupeM5c-6xy5-pvv2Q@mail.gmail.com>
References: <1362071814-12822-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:39833 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759887Ab3B1R5E convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 12:57:04 -0500
Received: by mail-oa0-f51.google.com with SMTP id h2so4157428oag.10
        for <netdev@vger.kernel.org>; Thu, 28 Feb 2013 09:57:04 -0800 (PST)
In-Reply-To: <1362071814-12822-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/2/28 Hauke Mehrtens <hauke@hauke-m.de>:
> Do not include the frame check sequence when adding the skb to
> netif_receive_skb(). This causes problems when this interface was
> bridged to a wifi ap and a big package should be forwarded from this
> Ethernet driver through a bride to the wifi client.

Is this a real fix?

Don't get me wrong, but it sounds a little like a workaround for some
issue in another network layer ;)

--=20
Rafa=C5=82
