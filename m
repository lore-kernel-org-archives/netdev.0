From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 1/1] Constify struct sysfs_ops for v2.6.33-rc4
Date: Sun, 17 Jan 2010 17:35:21 -0800
Message-ID: <20100118013521.GA4190@suse.de>
References: <4B5338D6.2050209@gmail.com>
 <20100117182537.GQ19799@ZenIV.linux.org.uk>
 <4B536FF5.3000705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-kernel@vger.kernel.org,
	teigland@redhat.com, Matt_Domsch@dell.com,
	maciej.sosnowski@intel.com, hjk@linutronix.de,
	Pekka Enberg <penberg@cs.helsinki.fi>, jens.axboe@oracle.com,
	shemminger@vyatta.com, akpm@linux-foundation.org,
	davem@davemloft.net, torvalds@linux-foundation.org,
	netdev@vger.kernel.org
To: Emese Revfy <re.emese@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755828Ab0ARSSv@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B536FF5.3000705@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 17, 2010 at 09:15:49PM +0100, Emese Revfy wrote:
> Al Viro wrote:
> > On Sun, Jan 17, 2010 at 05:20:38PM +0100, Emese Revfy wrote:
> > 
> >> Signed-off-by: Emese Revfy <re.emese@gmail.com>
> >> Acked-by: David Teigland <teigland@redhat.com>
> >> Acked-by: Matt Domsch <Matt_Domsch@dell.com>
> >> Acked-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
> >> Acked-by: Hans J. Koch <hjk@linutronix.de>
> >> Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>
> >> Acked-by: Jens Axboe <jens.axboe@oracle.com>
> >> Acked-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > NACKed-by: Al Viro <viro@zeniv.linux.org.uk>
> > 
> > Same reason.
> > 
> >> -        ssize_t (*show)(struct kobject *, struct attribute *, char *);
> >> -        ssize_t (*store)(struct kobject *, struct attribute *, const char *);
> >> +        ssize_t (* const show)(struct kobject *, struct attribute *, char *);
> >> +        ssize_t (* const store)(struct kobject *, struct attribute *, const char *);
> > 
> 
> Ok, I removed the field constification, here's the updated patch:

Please resend with proper changelog and other information so that it
could be applied.

thanks,

greg k-h
