From: Bhavesh Davda <bhavesh@vmware.com>
Subject: Re: [PATCH net-next] vmxnet3: prevent div-by-zero panic when ring
 resizing uninitialized dev
Date: Wed, 6 Mar 2013 14:00:11 -0800 (PST)
Message-ID: <591552351.12774238.1362607211741.JavaMail.root@vmware.com>
References: <20130306.153841.784919874486534382.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com, sbhatewara@vmware.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130306.153841.784919874486534382.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > ---
> >  drivers/net/vmxnet3/vmxnet3_drv.c     |    3 ++-
> >  drivers/net/vmxnet3/vmxnet3_ethtool.c |    6 ++++++
> >  drivers/net/vmxnet3/vmxnet3_int.h     |    4 ++--
> >  3 files changed, 10 insertions(+), 3 deletions(-)
> > 
> > diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c
> > b/drivers/net/vmxnet3/vmxnet3_drv.c
> > index 4aad350..bfc5898 100644
> > --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> > +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> > @@ -2922,7 +2922,7 @@ vmxnet3_probe_device(struct pci_dev *pdev,
> >  				    (int)num_online_cpus());
> >  	else
> >  #endif
> > -		num_rx_queues = 1;
> > +	num_rx_queues = 1;
> 
> Why are you un-indenting this else branch?  Please don't do that
> 

Just to annoy you :) [Sorry, couldn't resist.]

I'm sorry I didn't notice I was breaking the indent of the else branch. For some reason checkpatch didn't complain.

While at it, I'm also changing the netdev_info to netdev_err in vmxnet3_ethtool.c.

You didn't explicitly ask for it, so I wasn't sure if I should repost the patch. I'm going to repost it any way and leave it up to you on which patch you want to apply.

Thanks.

- Bhavesh
