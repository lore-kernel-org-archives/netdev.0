From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: Re: [ANNOUNCE] d80211 based driver for Intel PRO/Wireless 3945ABG
Date: Fri, 09 Feb 2007 17:43:41 -0500
Message-ID: <1171061021.7039.7.camel@dv>
References: <45CCE3CA.4050904@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: James Ketrenos <jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <45CCE3CA.4050904-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello, James!

On Fri, 2007-02-09 at 13:12 -0800, James Ketrenos wrote:

> You can find the new driver, and additional information about it, here:
> 
>    http://intellinuxwireless.org/iwlwifi.

I cannot get it through git:

$ git-clone http://intellinuxwireless.org/repos/iwlwifi.git
Initialized empty Git repository in /home/proski/src/iwlwifi/.git/
Cannot get remote repository information.
Perhaps git-update-server-info needs to be run there?

Perhaps git is right?  There is no info/refs there.

> You can find that package at:
> 
>    http://intellinuxwireless.org/d80211

I appreciate that you are doing this.  But it doesn't compile against
kernels compiled outside the tree:

grep: /lib/modules/2.6.20/build//include/linux/netdevice.h: No such file
or directory

Apparently it should be looking into /lib/modules/2.6.20/source as well.
That was a problem with the official ipw3945 drivers as well.

-- 
Regards,
Pavel Roskin

-
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
