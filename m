From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 1/2] net: break include loop netdevice.h, dsa.h,
 devlink.h
Date: Tue, 28 Mar 2017 15:04:30 -0700
Message-ID: <224a8890-5eaa-34cf-107b-70718a9c37e5@gmail.com>
References: <1490737507-7864-1-git-send-email-andrew@lunn.ch>
 <1490737507-7864-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org,
        linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1490737507-7864-2-git-send-email-andrew-g2DYL2Zd6BY@public.gmane.org>
Sender: linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/28/2017 02:45 PM, Andrew Lunn wrote:
> There is an include loop between netdevice.h, dsa.h, devlink.h because
> of NETDEV_ALIGN, making it impossible to use devlink structures in
> dsa.h.
> 
> Break this loop by taking dsa.h out of netdevice.h, add a forward
> declaration of dsa_switch_tree and netdev_set_default_ethtool_ops()
> function, which is what netdevice.h requires.
> 
> No longer having dsa.h in netdevice.h means the includes in dsa.h no
> longer get included. This breaks a few other files which depend on
> these includes. Add these directly in the affected file.
> 
> Signed-off-by: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>

Woah, thanks for doing this!

Reviewed-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
--
Florian
