From: David Miller <davem@davemloft.net>
Subject: Re: Please pull 'adm8211' branch of wireless-2.6
Date: Sat, 15 Sep 2007 21:50:53 -0700 (PDT)
Message-ID: <20070915.215053.74746915.davem@davemloft.net>
References: <200709152017.02646.flamingice@sourmilk.net>
	<46EC7F33.2050206@garzik.org>
	<200709160047.45128.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: flamingice@sourmilk.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42003
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750773AbXIPEuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 00:50:54 -0400
In-Reply-To: <200709160047.45128.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Wu <flamingice@sourmilk.net>
Date: Sun, 16 Sep 2007 00:47:40 -0400

> Huh? How does a driver use NAPI if it can't pass a struct net_device?

It is now managed by a struct napi_struct which you can embed into any
object you like.

NAPI is now totally disconnected from the network device structure.
This was necessary for proper support of multi-queue cards.

