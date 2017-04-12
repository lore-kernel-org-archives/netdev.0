From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 0/3] of: Make of_match_node() an inline stub for CONFIG_OF=n
Date: Tue, 11 Apr 2017 21:41:53 -0700
Message-ID: <20170412044156.17351-1-f.fainelli@gmail.com>
Cc: andrew-g2DYL2Zd6BY@public.gmane.org, vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Lee Jones <lee.jones-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Nicolas Ferre <nicolas.ferre-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:NETWORKING DRIVERS),
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:OPEN FIRMWARE AND FLATTENED
        DEVICE TREE)
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi all,

This patch series makes of_match_node() an inline stub for CONFIG_OF=n. kbuild
reported two build errors which are fixed as preriquisite patches.

This is based on Linus' master, not sure which tree would merge this, Frank's?

Thanks!

Florian Fainelli (3):
  mfd: max8998: Remove CONFIG_OF around max8998_dt_match
  net: macb: Remove CONFIG_OF around DT match table
  of: Make of_match_node() an inline stub for CONFIG_OF=n

 drivers/mfd/max8998.c               | 2 --
 drivers/net/ethernet/cadence/macb.c | 2 --
 include/linux/of.h                  | 6 +++++-
 3 files changed, 5 insertions(+), 5 deletions(-)

-- 
2.9.3

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
