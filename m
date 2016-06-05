From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 00/13] net: hns: add support of ACPI
Date: Sat, 04 Jun 2016 22:13:17 -0400 (EDT)
Message-ID: <20160604.221317.941727866999198396.davem@davemloft.net>
References: <1464922521-30928-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rjw@rjwysocki.net, lenb@kernel.org, fengguang.wu@intel.com,
	andriy.shevchenko@linux.intel.com, andrew@lunn.ch,
	ivecera@redhat.com, f.fainelli@gmail.com, haifeng.wei@huawei.com,
	charles.chenxin@huawei.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org,
	linuxarm@huawei.com
To: Yisen.Zhuang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53842 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241AbcFECNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2016 22:13:22 -0400
In-Reply-To: <1464922521-30928-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Date: Fri, 3 Jun 2016 10:55:08 +0800

> From: Kejian Yan <yankejian@huawei.com>
> 
> This series adds HNS support of acpi. The routine will call some ACPI
> helper functions, like acpi_dev_found() and acpi_evaluate_dsm(), which
> are not included in other cases. In order to make system compile
> successfully in other cases except ACPI, it needs to add relative stub
> functions to linux/acpi.h. And we use device property functions instead
> of serial helper functions to suport both DT and ACPI cases. And then
> add the supports of ACPI for HNS.
> 
> change log:
>  v3->v4:
>   mii-id gets from dev-name instead of address
> 
>  v2->v3:
>  1. add Review-by: Andy Shevchenko
>  2. fix the potential memory leak
> 
>  v1 -> v2:
>  1. use acpi_dev_found() instead of acpi_match_device_ids() to check if
> it is a acpi node.
>  2. use is_of_node() instead of IS_ENABLED() to check if it is a DT node.
>  3. split the patch("add support of acpi for hns-mdio") into two patches:
>     3.1 Move to use fwnode_handle
>     3.2 Add ACPI
>  4. add the patch which subject is dsaf misc operation method
>  5. fix the comments by Andy Shevchenko

Series applied, thanks.
