From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 1/10] cxgb3 - main header files
Date: Tue, 09 Jan 2007 02:19:14 -0800
Message-ID: <45A36C22.6010009@chelsio.com>
References: <20061220124125.6286.17148.stgit@localhost.localdomain> <45918CA4.3020601@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:27703 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbXAIKTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 05:19:31 -0500
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <45918CA4.3020601@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Divy Le Ray wrote:
>> From: Divy Le Ray <divy@chelsio.com>
>>
>> This patch implements the main header files of
>> the Chelsio T3 network driver.
>>
>> Signed-off-by: Divy Le Ray <divy@chelsio.com>
>
> Once you think it's ready, email me a URL to a single patch that adds 
> the driver to the latest linux-2.6.git kernel.  Include in the email a 
> description of the driver and signed-off-by line, which will get 
> directly included in the git changelog.
>
> Adding new drivers is a bit special, because we want to merge it as a 
> single changeset, but that would create a patch too large to review on 
> the common kernel mailing lists.
Jeff,

You can grab the monolithic patch at this URL:
http://service.chelsio.com/kernel.org/cxgb3.patch.bz2

This patch adds support for the latest 1G/10G Chelsio adapter, T3.
It is required by the T3 RDMA driver Steve Wise submitted.

Here is a brief description of its content:

drivers/net/cxgb3/adapter.h,
drivers/net/cxgb3/common.h,
drivers/net/cxgb3/cxgb3_ioctl.h,
drivers/net/cxgb3/firmware_exports.h:
    main header files

drivers/net/cxgb3/cxgb3_main.c
    main source file

drivers/net/cxgb3/t3_hw.c
    HW access routines

drivers/net/cxgb3/sge.c,
drivers/net/cxgb3/sge_defs.h
    scatter/gather engine

drivers/net/cxgb3/ael1002.c,
drivers/net/cxgb3/mc5.c,
drivers/net/cxgb3/vsc8211.c,
drivers/net/cxgb3/xgmac.c
    on board memory, MAC and PHY management

drivers/net/cxgb3/cxgb3_ctl_defs.h,
drivers/net/cxgb3/cxgb3_defs.h,
drivers/net/cxgb3/cxgb3_offload.h,
drivers/net/cxgb3/l2t.h, drivers/net/cxgb3/t3_cpl.h,
drivers/net/cxgb3/t3cdev.h
    offload operations header files

drivers/net/cxgb3/cxgb3_offload.c,
drivers/net/cxgb3/l2t.c
    offload capabilities

drivers/net/cxgb3/regs.h
    register definitions

drivers/net/Kconfig
drivers/net/Makefile
drivers/net/cxgb3/Makefile
drivers/net/cxgb3/version.h
    build files and versioning

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---
