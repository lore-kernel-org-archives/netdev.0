From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 1/2] Sysfs net class - infrastructure
Date: Thu, 15 May 2003 17:58:10 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030515.175810.42792746.davem@redhat.com>
References: <20030515162717.477fb84b.shemminger@osdl.org>
	<20030516002023.GA11926@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, mochel@osdl.org, netdev@oss.sgi.com,
   jkenisto@us.ibm.com, lkessler@us.ibm.com, dsteklof@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: greg@kroah.com
In-Reply-To: <20030516002023.GA11926@kroah.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Greg KH <greg@kroah.com>
   Date: Thu, 15 May 2003 17:20:23 -0700

   On Thu, May 15, 2003 at 04:27:17PM -0700, Stephen Hemminger wrote:
   > +#ifdef CONFIG_NET_SYSFS
   
   No, do not make this a config option.

I agree.
   > +	/* statistics object */
   > +	struct kobject		stats_kobj;
   
   What is this needed for?  I don't remember seeing this in your previous
   patches :)

He provides a sub-directory containing statistic value files.
I have no problem with this.
