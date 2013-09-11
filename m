From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tilegx driver: avoid compiler warning
Date: Wed, 11 Sep 2013 16:58:14 -0400 (EDT)
Message-ID: <20130911.165814.2091435893983550695.davem@davemloft.net>
References: <201309091822.r89IMXmA032018@farm-0002.internal.tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: cmetcalf@tilera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201309091822.r89IMXmA032018@farm-0002.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Mon, 9 Sep 2013 14:11:54 -0400

> The "id" variable was being incremented in common code, but only
> initialized and used in IPv4 code.  We move the increment to the IPv4
> code too, and then legitimately use the uninitialized_var() macro to
> avoid the gcc 4.6 warning that 'id' may be used uninitialized.
> Note that gcc 4.7 does not warn.
> 
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>

Ugly situation, but whatever, applied :-)
