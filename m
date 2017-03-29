From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 0/2] break include loop and dsa devlink support
Date: Tue, 28 Mar 2017 22:46:20 -0700 (PDT)
Message-ID: <20170328.224620.578507195105981119.davem@davemloft.net>
References: <1490737507-7864-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org,
        linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org
To: andrew-g2DYL2Zd6BY@public.gmane.org
Return-path: <linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1490737507-7864-1-git-send-email-andrew-g2DYL2Zd6BY@public.gmane.org>
Sender: linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Date: Tue, 28 Mar 2017 23:45:05 +0200

> These two patches add very basic support for devlink to DSA, in
> preparation for playing with dpipe.
> 
> The first patch is needed to break an include loop between
> netdevice.h, dsa.h and devlink.h. We need to remove dsa.h from
> netdevice.h. As a result, some files fail to compile, because they
> require includes pulled in via dsa.h. So this patch adds a number of
> includes in various places. The majority is within the network
> subsystem, but cifs also needs a few fixes.
> 
> 0-day has been chewing on this for over a day now, and not found any
> breakage. But Arnd's randconfig might uncover something.

Looks good, series applied, thanks.
