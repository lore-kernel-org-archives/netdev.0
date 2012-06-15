From: David Miller <davem@davemloft.net>
Subject: Re: [patch] qlcnic: off by one in qlcnic_init_pci_info()
Date: Fri, 15 Jun 2012 15:31:40 -0700 (PDT)
Message-ID: <20120615.153140.145606090941949521.davem@davemloft.net>
References: <20120614183424.GC6383@elgon.mountain>
	<CC000197.32F56%anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, sony.chacko@qlogic.com,
	Linux-Driver@qlogic.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: anirban.chakraborty@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51815 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758316Ab2FOWbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2012 18:31:40 -0400
In-Reply-To: <CC000197.32F56%anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Date: Thu, 14 Jun 2012 21:03:14 -0700

> 
> 
> On 6/14/12 11:34 AM, "Dan Carpenter" <dan.carpenter@oracle.com> wrote:
> 
>>The adapter->npars[] array has QLCNIC_MAX_PCI_FUNC elements.  We
>>allocate it that way a few lines earlier in the function.  So this test
>>is off by one.
>>
>>Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
 ...
> Acked-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>

Applied.
