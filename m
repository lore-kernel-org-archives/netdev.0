From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: rework port state setter
Date: Thu, 10 Mar 2016 16:11:30 -0500 (EST)
Message-ID: <20160310.161130.1092102174723373091.davem@davemloft.net>
References: <1457393057-22618-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, andrew@lunn.ch,
	kevin.smith@elecsyscorp.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457393057-22618-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Mon,  7 Mar 2016 18:24:17 -0500

> Apply a few non-functional changes on the port state setter:
> 
>   * add a dynamic debug message with state names to track changes
>   * explicit states checking instead of assuming their numeric values
>   * lock mutex only once when changing several port states
>   * use bitmap macros to declare and access port_state_update_mask
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
