From: "Gole, Anant" <anantgole@ti.com>
Subject: RE: [PATCH] net-next:can: add TI CAN (HECC) driver
Date: Tue, 1 Sep 2009 15:02:00 +0530
Message-ID: <2A3DCF3DA181AD40BDE86A3150B27B6B02F6211B1A@dbde02.ent.ti.com>
References: <1251458282-4674-1-git-send-email-anantgole@ti.com>
 <20090901090427.GA3199@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "socketcan-core@lists.berlios.de" <socketcan-core@lists.berlios.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:57955 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753240AbZIAJcW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 05:32:22 -0400
In-Reply-To: <20090901090427.GA3199@pengutronix.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[snip]
>>
>> This driver is tested on OMAP3517 EVM. Suspend/Resume not tested as yet.
>
>One minor thing I found while glimpsing at the code...
>
[snip]
>> +	}
>> +	if (!request_mem_region(mem->start, (mem->end - mem->start) + 1,
>
>Use resource_size(mem).
>
>> +		pdev->name)) {
>> +		printk(KERN_ERR "HECC region already claimed\n");
>> +		err = -EBUSY;
>> +		goto probe_exit;
>> +	}
>> +	addr = ioremap(mem->start, mem->end - mem->start + 1);
>
>ditto

Ack. Thanks for the comment. I will include in V2 patch.

Regards,
Anant
