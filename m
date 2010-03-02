From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: linux-next: Tree for March 1 (bluetooth/hci_sysfs)
Date: Mon, 01 Mar 2010 23:06:18 -0800
Message-ID: <1267513578.2710.1.camel@localhost.localdomain>
References: <20100301210210.c6f465e6.sfr@canb.auug.org.au>
	 <4B8C2CC5.8000603@oracle.com>
	 <20100302121526.36a1ea88.sfr@canb.auug.org.au>
	 <20100301.181415.266447389.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org, randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100301.181415.266447389.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

> >> static ssize_t inquiry_cache_read(struct file *file, char __user *userbuf,
> >> 						size_t count, loff_t *ppos)
> >> {
> >> 	struct hci_dev *hdev = file->private_data;
> >> 	struct inquiry_cache *cache = &hdev->inq_cache;
> >> 	struct inquiry_entry *e;
> >> 	char buf[4096]; // <<<<<<<<<<<<<<<<<<<<<<<<<<< huh? don't do that on stack.
> >> 	int n = 0;
> > 
> > Dave Miller is following up on that.
> 
> This looks like a job for.... SEQ FILE! :-)
> 
> I'm testing the following fix.

the patch looks good, but it doesn't do the job. I have to look into why
that is. Will try to come up with a proper patch soon.

Regards

Marcel
