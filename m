From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 1/2] Sysfs net class - infrastructure
Date: Thu, 15 May 2003 17:20:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030516002023.GA11926@kroah.com>
References: <20030515162717.477fb84b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, Patrick Mochel <mochel@osdl.org>,
   netdev@oss.sgi.com, jkenisto@us.ibm.com, lkessler@us.ibm.com,
   Daniel Stekloff <dsteklof@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030515162717.477fb84b.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 15, 2003 at 04:27:17PM -0700, Stephen Hemminger wrote:
> +#ifdef CONFIG_NET_SYSFS

No, do not make this a config option.  sysfs is not a config option, and
no other subsystem has this kind of option.  It should always be enabled
so that userspace tools know it will always be present.

If we want to start worrying about CONFIG_TINY or something, then we can
possibly start to implement something like this.  But for now, no, the
overhead is very minimal (compared to something like SCSI for example.)


> +	/* statistics object */
> +	struct kobject		stats_kobj;

What is this needed for?  I don't remember seeing this in your previous
patches :)

thanks,

greg k-h
