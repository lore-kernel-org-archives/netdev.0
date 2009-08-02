From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pcnet32: VLB support fixes
Date: Sun, 02 Aug 2009 12:30:33 -0700 (PDT)
Message-ID: <20090802.123033.168343935.davem@davemloft.net>
References: <200907302317.52648.bzolnier@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pcnet32@verizon.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, error27@gmail.com, corbet@lwn.net,
	eteo@redhat.com, julia@diku.dk
To: bzolnier@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753474AbZHBTa3@vger.kernel.org>
In-Reply-To: <200907302317.52648.bzolnier@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Date: Thu, 30 Jul 2009 23:17:52 +0200

> From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
> Subject: [PATCH] pcnet32: VLB support fixes
> 
> VLB support has been broken since at least 2004-2005 period as some
> changes introduced back then assumed that ->pci_dev is always valid,
> lets try to fix it:
> 
> - remove duplicated SET_NETDEV_DEV() call
> 
> - call SET_NETDEV_DEV() only for PCI devices
> 
> - check for ->pci_dev validity in pcnet32_open()
> 
> [ Alternatively we may consider removing VLB support but there would not
>   be much gain in it since an extra driver code needed for VLB support is
>   minimal and quite simple. ]
> 
> This takes care of the following entry from Dan's list:
> 
> drivers/net/pcnet32.c +1889 pcnet32_probe1(298) warning: variable derefenced before check 'pdev'
> 
> Reported-by: Dan Carpenter <error27@gmail.com>
> Signed-off-by: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>

Also applied, thanks.
