From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: fix preparation of a port STP update
Date: Tue, 29 Sep 2015 21:37:11 -0700 (PDT)
Message-ID: <20150929.213711.40970808547534906.davem@davemloft.net>
References: <1443550674-26537-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443550674-26537-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 29 Sep 2015 14:17:54 -0400

> Because of the default 0 value of ret in dsa_slave_port_attr_set, a
> driver may return -EOPNOTSUPP from the commit phase of a STP state,
> which triggers a WARN() from switchdev.
> 
> This happened on a 6185 switch which does not support hardware bridging.
> 
> Fixes: 3563606258cf ("switchdev: convert STP update to switchdev attr set")
> Reported-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied and queued up for -stable, thanks.
