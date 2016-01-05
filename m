From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/1 v2] include/uapi/linux/sockios.h: mark SIOCRTMSG
 unused
Date: Tue, 05 Jan 2016 16:44:22 -0500 (EST)
Message-ID: <20160105.164422.955902617951180797.davem@davemloft.net>
References: <20160104.171953.1963808714374349079.davem@davemloft.net>
	<1451985169-4622-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org,
	yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: xypron.glpk-Mmb7MZpHnFY@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1451985169-4622-1-git-send-email-xypron.glpk-Mmb7MZpHnFY@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Heinrich Schuchardt <xypron.glpk-Mmb7MZpHnFY@public.gmane.org>
Date: Tue,  5 Jan 2016 10:12:49 +0100

> IOCTL SIOCRTMSG does nothing but return EINVAL.
> 
> So comment it as unused.
> 
> SIOCRTMSG is only used in:
> * net/ipv4/af_inet.c
> * include/uapi/linux/sockios.h
> 
> inet_ioctl calls ip_rt_ioctl.
> ip_rt_ioctl only handles SIOCADDRT and SIOCDELRT and returns -EINVAL
> otherwise.
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk-Mmb7MZpHnFY@public.gmane.org>

Applied, thanks.
