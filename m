From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/13] tile: handle 64-bit statistics in tilepro
 network driver
Date: Wed, 24 Jul 2013 02:31:26 -0700 (PDT)
Message-ID: <20130724.023126.792508581970927723.davem@davemloft.net>
References: <cover.1374609948.git.cmetcalf@tilera.com>
	<40362053a9f02d56a4f0c07a9982d96203723ec8.1374609948.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: cmetcalf@tilera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <40362053a9f02d56a4f0c07a9982d96203723ec8.1374609948.git.cmetcalf@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Tue, 23 Jul 2013 16:05:48 -0400

> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>

I'm pretty sure that you need to make use of the primitives in
include/linux/u64_stats_sync.h if you want to use 64-bit statistics
in this way.
