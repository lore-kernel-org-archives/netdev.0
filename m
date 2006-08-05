From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take4 1/4] kevent: Core files.
Date: Sat, 5 Aug 2006 22:10:47 +0400
Message-ID: <20060805181047.GA22177@2ka.mipt.ru>
References: <11547829553148@2ka.mipt.ru> <11547829581556@2ka.mipt.ru> <20060805175702.GA27992@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422659AbWHESLR@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Content-Disposition: inline
In-Reply-To: <20060805175702.GA27992@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 05, 2006 at 10:57:02AM -0700, GregKH (greg@kroah.com) wrote:
> > +	dev = class_device_create(kevent_user_class, NULL, 
> > +			MKDEV(kevent_user_major, 0), NULL, kevent_name);
> > +	if (IS_ERR(dev)) {
> > +		printk(KERN_ERR "Failed to create %d.%d class device in \"%s\" class: err=%ld.\n", 
> > +				kevent_user_major, 0, kevent_name, PTR_ERR(dev));
> > +		err = PTR_ERR(dev);
> > +		goto err_out_class_destroy;
> > +	}
> 
> As you are only using 1 minor number in this code, why not just use a
> miscdevice instead?  It saves a bit of overhead and makes the code a
> tiny bit smaller :)

No problem. I will move it to miscdevice instead of full chardev.

> thanks,
> 
> greg k-h

-- 
	Evgeniy Polyakov
