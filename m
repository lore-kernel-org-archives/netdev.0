From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/6] net: switchdev: use specific
 switchdev_obj_*
Date: Tue, 29 Sep 2015 21:32:32 -0700 (PDT)
Message-ID: <20150929.213232.861100072512358746.davem@davemloft.net>
References: <1443542838-19234-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, sfeldma@gmail.com, jiri@resnulli.us,
	f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443542838-19234-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 29 Sep 2015 12:07:12 -0400

> This patchset changes switchdev add, del, dump operations from this:
 ...
> to something similar to the notifier_call callback of a notifier_block:
 ...
> This allows the caller to pass and expect back a specific switchdev_obj_*
> structure (e.g. switchdev_obj_fdb) instead of the generic switchdev_obj one.
> 
> This will simplify pushing the callback function down to the drivers.
> 
> The first 3 patches get rid of the dev parameter of the dump callback, since it
> is not always neeeded (e.g. vlan_dump) and some drivers (such as DSA drivers)
> may not have easy access to it.
> 
> Patches 4 and 5 implement the change in the switchdev operations and its users.
> 
> Patch 6 extracts the inner switchdev_obj_* structures from switchdev_obj and
> removes this last one.
> 
> v2: fix error spotted by kbuild (extra ';' inline switchdev_port_obj_dump).

Series applied, thanks Vivien.
