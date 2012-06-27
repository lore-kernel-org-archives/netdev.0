From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] 6lowpan: double unlock on an error path
Date: Wed, 27 Jun 2012 01:17:05 -0700 (PDT)
Message-ID: <20120627.011705.1325190861280829179.davem@davemloft.net>
References: <20120627065309.GA25774@elgon.mountain>
	<CAJmB2rCwYo1KR_gOQFrvMn2A2px1mPEN5DV+KGtjV914p-o7NA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dan.carpenter@oracle.com, dbaryshkov@gmail.com, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40251 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752408Ab2F0IRG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 04:17:06 -0400
In-Reply-To: <CAJmB2rCwYo1KR_gOQFrvMn2A2px1mPEN5DV+KGtjV914p-o7NA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Date: Wed, 27 Jun 2012 10:57:18 +0400

> 2012/6/27 Dan Carpenter <dan.carpenter@oracle.com>:
>> We already unlocked a few lines earlier here, so we can go directly =
to
>> drop without passing through unlock. =A0This was introduced recently=
 in
>> c5d3687f6c ('6lowpan: read data from skb safely').
>>
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
 ...
> Acked-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>

Applied, thanks.
