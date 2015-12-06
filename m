From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Revert "i40e: remove CONFIG_I40E_VXLAN"
Date: Sun, 06 Dec 2015 11:23:55 -0500 (EST)
Message-ID: <20151206.112355.1485488163212149377.davem@davemloft.net>
References: <1449215371-18357-1-git-send-email-anjali.singhai@intel.com>
	<20151205.175019.927737740812545846.davem@davemloft.net>
	<CAL3LdT5x=8K4fUgL28PzWci_5UWmbSOTcJQwbmKOGzvH0T6PuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anjali.singhai@intel.com, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52746 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753600AbbLFQX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2015 11:23:57 -0500
In-Reply-To: <CAL3LdT5x=8K4fUgL28PzWci_5UWmbSOTcJQwbmKOGzvH0T6PuA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 5 Dec 2015 23:13:31 -0800

> On Sat, Dec 5, 2015 at 2:50 PM, David Miller <davem@davemloft.net> wrote:
>> From: Anjali Singhai Jain <anjali.singhai@intel.com>
>> Date: Thu,  3 Dec 2015 23:49:31 -0800
>>
>>> This reverts commit 8fe269991aece394a7ed274f525d96c73f94109a.
>>> The case where VXLAN is a module and i40e driver is inbuilt
>>> will not be handled properly with this change since i40e
>>> will have an undefined symbol vxlan_get_rx_port in it.
>>>
>>> v2: Add a signed-off-by.
>>>
>>> Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
>>
>> Why isn't this going via Jeff Kirsher?  And why isn't he even
>> CC:'d?
> 
> Not sure why either... but for what it is worth, the revert has my blessing.
> 
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
