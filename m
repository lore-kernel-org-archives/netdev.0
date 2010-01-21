From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e1000/e1000e/igb/igbvf/ixgb/ixgbe: Fix tests
 of unsigned in *_tx_map()
Date: Wed, 20 Jan 2010 16:21:46 -0800 (PST)
Message-ID: <20100120.162146.16506078.davem@davemloft.net>
References: <20100120002126.25572.29661.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, roel.kluin@gmail.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50131
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754842Ab0AUAVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 19:21:36 -0500
In-Reply-To: <20100120002126.25572.29661.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 19 Jan 2010 16:21:45 -0800

> From: Roel Kluin <roel.kluin@gmail.com>
> 
> The variable count and i are unsigned so the (<|>=)0 tests do not work.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
