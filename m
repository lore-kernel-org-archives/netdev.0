From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] vxlan: Allow setting destination to unicast address.
Date: Tue, 16 Apr 2013 16:39:34 -0400 (EDT)
Message-ID: <20130416.163934.1716734316538374556.davem@davemloft.net>
References: <877gk2r64z.wl%atzm@stratosphere.co.jp>
	<OF88AC4A33.EEA9E994-ON85257B4F.004C7B68-85257B4F.004C901F@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: atzm@stratosphere.co.jp, mike.rapoport@ravellosystems.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	stephen@networkplumber.org, xiyou.wangcong@gmail.com
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49782 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965164Ab3DPUjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 16:39:36 -0400
In-Reply-To: <OF88AC4A33.EEA9E994-ON85257B4F.004C7B68-85257B4F.004C901F@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Stevens <dlstevens@us.ibm.com>
Date: Tue, 16 Apr 2013 09:56:15 -0400

> netdev-owner@vger.kernel.org wrote on 04/16/2013 08:50:52 AM:
> 
>> From: Atzm Watanabe <atzm@stratosphere.co.jp>
> 
>> This patch allows setting VXLAN destination to unicast address.
>> It allows that VXLAN can be used as peer-to-peer tunnel without
>> multicast.
>> 
>> v4: generalize struct vxlan_dev, "gaddr" is replaced with vxlan_rdst.
>>     "GROUP" attribute is replaced with "REMOTE".
>>     they are based by David Stevens's comments.
>> 
>> v3: move a new attribute REMOTE into the last of an enum list
>>     based by Stephen Hemminger's comments.
>> 
>> v2: use a new attribute REMOTE instead of GROUP based by
>>     Cong Wang's comments.
>> 
>> Signed-off-by: Atzm Watanabe <atzm@stratosphere.co.jp>
> 
> Acked-by: David L Stevens <dlstevens@us.ibm.com>

Applied.
