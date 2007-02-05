From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 0/3] NetXen: 1G/10G Ethernet Driver updates
Date: Mon, 5 Feb 2007 07:31:17 -0800
Message-ID: <200702051531.l15FVHr9008504@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, netxenproj@linsyssoft.com,
	rob@netxen.com, sanjeev@netxen.com, wendyx@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:27423 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932671AbXBEPb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 10:31:26 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

I will be sending NetXen: 1G/10G Ethernet Driver updates with respect to 
netdev #master in the subsequent emails.

We have incorporated the feedbacks we got for the patch on the ethtool 
support for user level tools, except for these:

Jeff Garzik wrote:
>is it ok to return without re-locking flash?

After flashing, we have to reboot the machine before we can use
the newer flash. So re-locking is not necessary.
Also its not possible to detect the end of flashing process, so as 
to lock the flash after that.

>>       netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 0);
>> -     udelay(100);            /* prevent bursting on CRB */
>> +     udelay(70);             /* prevent bursting on CRB */
Jeff Garzik wrote:
>why?

This is only to reduce the flashing time.

Thanks,
--Amit
~

