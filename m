From: Phil Sutter <phil-ydcDiazATMQ@public.gmane.org>
Subject: Re: strange behaviour of MC7700 with sierra_net
Date: Thu, 4 Aug 2011 18:38:33 +0200
Message-ID: <20110804163833.GC15300@orbit.nwl.cc>
References: <20110727141246.GC29616@orbit.nwl.cc>
 <8F90F944E50427428C60E12A34A309D23424BB0F25@carmd-exchmb01.sierrawireless.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rory Filer <rfiler-usJ8hg9QsBLWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <8F90F944E50427428C60E12A34A309D23424BB0F25-3qf8vkpM5jTbmvMHnzRVpW3Pdy6AhKVLXbPIYa3/oNjDOqzlkpFKJg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Elina,

(Added the lists to CC again since others might benefit from the
provided information.)

On Tue, Aug 02, 2011 at 03:48:42PM -0700, Elina Pasheva wrote:
> Please note that we publish updates to sierra and sierra_net Linux drivers on Sierra Wireless Knowledge Base.
> http://www.sierrawireless.com/Support/knowledgebase.aspx
> 
> 
> Please find attached the latest published drivers (for kernel-2.6.38, but sierra_net may be ported to kernel-2.6.39 with almost no changes).
> 
> Would you please let me know if these work for you?
> 
> I have tried MC7700 device on kernel-2.6.38 with sierra v.1.7.40 and sierra_net v.3.0 Linux drivers.
> 
> Using a commercial sim card I do not see problems with sync as you described it.
> 
> Please let me know if it works better for you.

Thanks for the pointer! I've downloaded the DirectIP driver v3.0, which
indeed compiles against 2.6.39.2 without any changes at all. Also, the
SYNC problem is gone. Looking at the driver, it seems to be related to
the new function sierra_net_open() calling sierra_net_dosync() instead
of sierra_net_bind(). 

Other than that and the autopm-support, there are not many changes to
the driver. Are there concrete plans already when this will go mainline?

Greetings and again many thanks,
Phil
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
