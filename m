From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ATM: Fix wrong usage of INIT_WORK
Date: Thu, 07 Jul 2011 05:10:42 -0700 (PDT)
Message-ID: <20110707.051042.262327217189050013.davem@davemloft.net>
References: <1310039512-17579-1-git-send-email-wangshaoyan.pt@taobao.com>
	<20110707.045159.735589070219101177.davem@davemloft.net>
	<CANxBZFo_2P+hrjNDmvU0wai2CA7Ry3LJ9vk+pZ4ML1RR12LKTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wangshaoyan.pt@taobao.com,
	chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net
To: stufever@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42257 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755856Ab1GGMMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 08:12:53 -0400
In-Reply-To: <CANxBZFo_2P+hrjNDmvU0wai2CA7Ry3LJ9vk+pZ4ML1RR12LKTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Shaoyan <stufever@gmail.com>
Date: Thu, 7 Jul 2011 20:04:25 +0800

> I just don't know whether the marco FILL_RX_POOLS_IN_BH is useful?

Yes, another option is to delete all of the code protected by
that macro altogether.

It obviously hasn't been build tested in a long time, if at all.
