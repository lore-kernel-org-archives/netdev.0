From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: Re: [PATCH] adm8211: fix memory leak
Date: Mon, 12 Jul 2010 07:51:49 -0700
Message-ID: <20100712145149.GA2273@tux>
References: <1278764938-9417-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	Michael Wu <flamingice@sourmilk.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Kalle Valo <kalle.valo@iki.fi>,
	Luis Rodriguez <Luis.Rodriguez@Atheros.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Kulikov Vasiliy <segooon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.atheros.com ([12.36.123.2]:35171 "EHLO mail.atheros.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755809Ab0GLOvv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jul 2010 10:51:51 -0400
Received: from mail.atheros.com ([10.10.20.105])
	by sidewinder.atheros.com
	for <netdev@vger.kernel.org>; Mon, 12 Jul 2010 07:51:51 -0700
Content-Disposition: inline
In-Reply-To: <1278764938-9417-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 10, 2010 at 05:28:57AM -0700, Kulikov Vasiliy wrote:
> We must free priv->eeprom allocated in adm8211_read_eeprom().
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Acked-by: Luis R. Rodriguez <lrodriguez@atheros.com>

Good catch.

  Luis
