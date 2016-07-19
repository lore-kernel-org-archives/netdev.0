From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: switchdev: change ageing_time type to clock_t
Date: Tue, 19 Jul 2016 16:49:36 -0700 (PDT)
Message-ID: <20160719.164936.636648029845762035.davem@davemloft.net>
References: <20160718190206.18620-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, jiri@mellanox.com, sfeldma@gmail.com,
	idosch@mellanox.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40828 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752334AbcGSXth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 19:49:37 -0400
In-Reply-To: <20160718190206.18620-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Mon, 18 Jul 2016 15:02:06 -0400

> The switchdev value for the SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME
> attribute is a clock_t and requires to use helpers such as
> clock_t_to_jiffies() to convert to milliseconds.
> 
> Change ageing_time type from u32 to clock_t to make it explicit.
> 
> Fixes: f55ac58ae64c ("switchdev: add bridge ageing_time attribute")
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
