From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: call _mv88e6xxx_stats_wait with
 SMI lock held
Date: Mon, 03 Aug 2015 15:46:35 -0700 (PDT)
Message-ID: <20150803.154635.964762632357776736.davem@davemloft.net>
References: <1438607864-17829-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, linux@roeck-us.net, andrew@lunn.ch,
	f.fainelli@gmail.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438607864-17829-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Mon,  3 Aug 2015 09:17:44 -0400

> At switch setup, _mv88e6xxx_stats_wait was called without holding the
> SMI mutex. Fix this by requesting the lock for this call.
> 
> Also, return the _mv88e6xxx_stats_wait code, since it may fail.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied to net-next, thanks.
