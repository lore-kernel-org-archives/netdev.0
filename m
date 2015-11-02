From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: dsa: mv88e6xxx: assert SMI lock
Date: Mon, 02 Nov 2015 15:54:42 -0500 (EST)
Message-ID: <20151102.155442.1765578330537677152.davem@davemloft.net>
References: <1446245805-24128-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch,
	linux@roeck-us.net, narmstrong@baylibre.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446245805-24128-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri, 30 Oct 2015 18:56:45 -0400

> It's easy to forget to lock the smi_mutex before calling the low-level
> _mv88e6xxx_reg_{read,write}, so add a assert_smi_lock function in them.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
