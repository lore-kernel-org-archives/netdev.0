From: Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 0/3] of: Make of_match_node() an inline stub for
 CONFIG_OF=n
Date: Wed, 12 Apr 2017 20:46:42 -0700
Message-ID: <58EEF4A2.9070003@gmail.com>
References: <20170412044156.17351-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: andrew-g2DYL2Zd6BY@public.gmane.org, vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org,
        Lee Jones <lee.jones-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Nicolas Ferre <nicolas.ferre-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "open list:NETWORKING DRIVERS" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "open list:OPEN FIRMWARE AND FLATTENED DEVICE TREE"
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170412044156.17351-1-f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/11/17 21:41, Florian Fainelli wrote:
> Hi all,
> 
> This patch series makes of_match_node() an inline stub for CONFIG_OF=n. kbuild
> reported two build errors which are fixed as preriquisite patches.
> 
> This is based on Linus' master, not sure which tree would merge this, Frank's?

It would come in via Rob.

I am not comfortable with patch 3/3 at this moment.

Version 1 of the patch resulted in two errors from the kbuild test robot.  This
version results in another error from the kbuild test robot.  I know it is a
lot of work, but please look at all of the callers of of_match_node() and
check whether any of the other callers will have the same type of error that
the kbuild test robot is catching.

-Frank

> 
> Thanks!
> 
> Florian Fainelli (3):
>   mfd: max8998: Remove CONFIG_OF around max8998_dt_match
>   net: macb: Remove CONFIG_OF around DT match table
>   of: Make of_match_node() an inline stub for CONFIG_OF=n
> 
>  drivers/mfd/max8998.c               | 2 --
>  drivers/net/ethernet/cadence/macb.c | 2 --
>  include/linux/of.h                  | 6 +++++-
>  3 files changed, 5 insertions(+), 5 deletions(-)
> 

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
