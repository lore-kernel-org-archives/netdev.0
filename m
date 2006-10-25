From: "Randy.Dunlap" <randy.dunlap@oracle.com>
Subject: Re: How to grab a block of binary data w/out using ioctls?
Date: Tue, 24 Oct 2006 22:07:11 -0700
Message-ID: <453EF0FF.3070508@oracle.com>
References: <453D61E8.8020400@candelatech.com> <20061023215448.f4f6c95a.randy.dunlap@oracle.com> <20061024050014.GC12506@havoc.gtf.org> <453ECB2C.3070202@candelatech.com> <20061025024718.GB23769@havoc.gtf.org> <20061024213549.92cbbeb0.randy.dunlap@oracle.com> <20061025044621.GA32486@havoc.gtf.org> <453EED7F.2010806@oracle.com> <20061025050154.GC32486@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:45237 "EHLO
	rgminet01.oracle.com") by vger.kernel.org with ESMTP
	id S1161338AbWJYFFm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 01:05:42 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <20061025050154.GC32486@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> On Tue, Oct 24, 2006 at 09:52:15PM -0700, Randy.Dunlap wrote:
>> Thanks.  It's not the only one like that.  Also these 3 uses are incorrect 
>> AFAICT:
>>
>> ./drivers/firmware/dell_rbu.c:721:	rc = 
>> sysfs_create_bin_file(&rbu_device->dev.kobj, &rbu_data_attr);
> 
> this is ok

ack, thanks for looking.

>> ./drivers/firmware/dell_rbu.c:724:	rc = 
>> sysfs_create_bin_file(&rbu_device->dev.kobj, &rbu_image_type_attr);
>> ./drivers/firmware/dell_rbu.c:727:	rc = 
>> sysfs_create_bin_file(&rbu_device->dev.kobj,
> 
> these appear to be incorrect

-- 
~Randy
