From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: linux-next: Tree for March 1 (bluetooth/hci_sysfs)
Date: Tue, 02 Mar 2010 17:23:37 -0800
Message-ID: <1267579417.29510.6.camel@localhost.localdomain>
References: <20100301210210.c6f465e6.sfr@canb.auug.org.au>
	 <4B8C2CC5.8000603@oracle.com>
	 <20100302121526.36a1ea88.sfr@canb.auug.org.au>
	 <20100301.181415.266447389.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, randy.dunlap@oracle.com,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100301.181415.266447389.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
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

I have a working and tested patch that uses single_open(). Will send a
patch with commit message and everything in a bit so you can apply it.

Regards

Marcel
