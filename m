From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] net: dsa: check out-of-range ageing
 time
Date: Wed, 15 Mar 2017 15:34:44 -0700 (PDT)
Message-ID: <20170315.153444.911901357692024194.davem@davemloft.net>
References: <20170315195350.11059-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch,
        jcobham@questertangent.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170315195350.11059-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Wed, 15 Mar 2017 15:53:47 -0400

> The ageing time limits supported by DSA drivers vary depending on the
> switch model. If a driver returns -ERANGE for out-of-range values, the
> switchdev commit phase will fail with the following stacktrace:
 ...
> This patchset fixes this by adding ageing_time_min and ageing_time_max
> fields to the dsa_switch structure, which can optionally be set by a DSA
> driver.
> 
> If provided, the DSA core will check for out-of-range values in the
> SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME prepare phase and return -ERANGE
> accordingly.
> 
> Finally set these limits in the mv88e6xxx driver.

Series applied, thanks Vivien.
