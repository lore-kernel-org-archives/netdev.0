From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] mlx4: Query for loopback support
Date: Thu, 01 Oct 2009 13:34:44 -0700 (PDT)
Message-ID: <20091001.133444.116815514.davem@davemloft.net>
References: <4AC4BDB7.2040306@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34946
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756568AbZJAUeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 16:34:25 -0400
In-Reply-To: <4AC4BDB7.2040306@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Thu, 01 Oct 2009 16:33:27 +0200

> +	int			loopback_support;

You don't need a full 32-bit integer to store what
amounts to a single bit of boolean state.

Please store this in a flags word somewhere, or
if nothing appropriate exists, use a 'bool'.
