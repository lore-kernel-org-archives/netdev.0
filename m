From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [patch 1/4] network dev read_mostly
Date: Tue, 13 Mar 2007 06:37:21 +0100
Message-ID: <45F63891.6040307@cosmosbay.com>
References: <20070312210817.485320783@linux-foundation.org> <20070312210907.509184287@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:47029 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753125AbXCMFh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2007 01:37:28 -0400
In-Reply-To: <20070312210907.509184287@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger a =E9crit :
> For Eric, mark packet type and network device watermarks
> as read mostly.

;)

> =20
>  static DEFINE_SPINLOCK(ptype_lock);
> -static struct list_head ptype_base[16];	/* 16 way hashed list */
> -static struct list_head ptype_all;		/* Taps */
> +static struct list_head ptype_base[16] __read_mostly;	/* 16 way hash=
ed list */
> +static struct list_head ptype_all __read_mostly;	/* Taps */


what about netdev_nit ?

