From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] openvswitch: Use zerocopy if applicable
 when performing the upcall
Date: Mon, 10 Jun 2013 13:43:31 -0700 (PDT)
Message-ID: <20130610.134331.1301662479712409021.davem@davemloft.net>
References: <CAEP_g=944Wq982rDSC0hrqUBu8Sf6MCtQN0NhgyU5FDr9UB3ww@mail.gmail.com>
	<20130607122139.GA21856@casper.infradead.org>
	<CAEP_g=87=0bAP_QQVVXRXzqMA-9Xj5dXvsjpfe4MQ_k2x5n9cA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	dev@openvswitch.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59555 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752657Ab3FJUnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 16:43:32 -0400
In-Reply-To: <CAEP_g=87=0bAP_QQVVXRXzqMA-9Xj5dXvsjpfe4MQ_k2x5n9cA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Mon, 10 Jun 2013 13:34:23 -0700

> Well, this is the slow path. I don't want to force userspace to deal
> with this because it's an internal kernel optimization that is
> platform-specific and requires carrying additional metadata around.

I think the grounds for this rejection is over the top and
unreasonable.
