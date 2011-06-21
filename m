From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] packet: Add fanout support.
Date: Tue, 21 Jun 2011 14:39:02 -0700 (PDT)
Message-ID: <20110621.143902.274396574751811372.davem@davemloft.net>
References: <20110621.034627.30677905865798284.davem@davemloft.net>
	<BANLkTikgTqGY=S9UVik6wjSp5WE4WLmKtA@mail.gmail.com>
	<4E009C5A.8060208@inliniac.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: victor@inliniac.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39177 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613Ab1FUVjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 17:39:09 -0400
In-Reply-To: <4E009C5A.8060208@inliniac.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Victor Julien <victor@inliniac.net>
Date: Tue, 21 Jun 2011 15:27:54 +0200

> From a Suricata IDS point of view, I would need to have the
> fragments of a flow/tuple on the same socket.

Currently you would, they would all go to the first socket in
the fanout.
