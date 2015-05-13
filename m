From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [PATCH net-next] switchdev: add support for fdb add/del/dump
 via switchdev_port_obj ops.
Date: Tue, 12 May 2015 17:07:42 -0700
Message-ID: <555295CE.9090207@intel.com>
References: <1430949253-6358-1-git-send-email-sridhar.samudrala@intel.com> <20150512.182013.447321071616691313.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:23139 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964873AbbEMAHn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2015 20:07:43 -0400
In-Reply-To: <20150512.182013.447321071616691313.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 5/12/2015 3:20 PM, David Miller wrote:
> From: Sridhar Samudrala <sridhar.samudrala@intel.com>
> Date: Wed,  6 May 2015 14:54:13 -0700
>
>> - introduce port fdb obj and generic switchdev_port_fdb_add/del/dump()
>> - use switchdev_port_fdb_add/del/dump in rocker/team/bonding ndo ops.
>> - add support for fdb obj in switchdev_port_obj_add/del/dump()
>> - switch rocker to implement fdb ops via switchdev_ops
>>
>> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> What is this patch even against?  I don't see switchdev_port_obj_add()
> in any tree I maintain, yet this patch's context shows references to
> it which should exist already.

Sorry, I should have mentioned that this patch is on top of v5 version 
of Scott's switchdev spring cleanup patches.
Now that v7 version is merged, i will resubmit on top of net-next.

Thanks
Sridhar
