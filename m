From: Jeff Garzik <jeff@garzik.org>
Subject: Re: How to grab a block of binary data w/out using ioctls?
Date: Wed, 25 Oct 2006 01:01:54 -0400
Message-ID: <20061025050154.GC32486@havoc.gtf.org>
References: <453D61E8.8020400@candelatech.com> <20061023215448.f4f6c95a.randy.dunlap@oracle.com> <20061024050014.GC12506@havoc.gtf.org> <453ECB2C.3070202@candelatech.com> <20061025024718.GB23769@havoc.gtf.org> <20061024213549.92cbbeb0.randy.dunlap@oracle.com> <20061025044621.GA32486@havoc.gtf.org> <453EED7F.2010806@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:4070 "EHLO havoc.gtf.org")
	by vger.kernel.org with ESMTP id S1161326AbWJYFBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 01:01:54 -0400
To: "Randy.Dunlap" <randy.dunlap@oracle.com>
Content-Disposition: inline
In-Reply-To: <453EED7F.2010806@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 24, 2006 at 09:52:15PM -0700, Randy.Dunlap wrote:
> Thanks.  It's not the only one like that.  Also these 3 uses are incorrect 
> AFAICT:
> 
> ./drivers/firmware/dell_rbu.c:721:	rc = 
> sysfs_create_bin_file(&rbu_device->dev.kobj, &rbu_data_attr);

this is ok


> ./drivers/firmware/dell_rbu.c:724:	rc = 
> sysfs_create_bin_file(&rbu_device->dev.kobj, &rbu_image_type_attr);
> ./drivers/firmware/dell_rbu.c:727:	rc = 
> sysfs_create_bin_file(&rbu_device->dev.kobj,

these appear to be incorrect

	Jeff



