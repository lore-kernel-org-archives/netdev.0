From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [PATCH net-next v3] rocker: add debugfs support to dump internal
 tables
Date: Thu, 17 Mar 2016 16:48:33 -0400
Message-ID: <56EB1821.4050902@ti.com>
References: <CAE4R7bAwuZkoOqO1eA9pWQ35UPiSs7-Fm+AaedVU1wwiRZ=Jwg@mail.gmail.com>
 <20150818181930.GK4381@lunn.ch>
 <CAE4R7bA621-ySQuOJ_kLTSju7ZwD3Ur4oSAS0JCE4EjzEsRr7Q@mail.gmail.com>
 <20150818.134720.1520233036019988872.davem@davemloft.net>
 <56EB0F37.9090908@ti.com> <20160317202519.GA30210@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <sfeldma@gmail.com>,
	<netdev@vger.kernel.org>, <jiri@resnulli.us>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:41321 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932832AbcCQUsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 16:48:42 -0400
In-Reply-To: <20160317202519.GA30210@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/17/2016 04:25 PM, Andrew Lunn wrote:
> On Thu, Mar 17, 2016 at 04:10:31PM -0400, Murali Karicheri wrote:
>> David,
>>
>> On 08/18/2015 04:47 PM, David Miller wrote:
>>> I see some drivers where the foo_debugfs.c file is larger than the rest
>>> of the driver.  Once people start using it, it's like crack, and they
>>> dump every single debugging widget they found useful at some point into
>>> there.
>>>
>>> This is not what we want.  Most things I see in debugfs support was
>>> probably useful for debugging one particular bug but then it was never
>>> really useful again in the future.  Those kinds of things can be done
>>> locally in someone's tree.
>>>
>>> I often see various kinds of "statistics" ending up in these things,
>>> or register dumps, both of which are 'ethtool' or similar material.
>> Very late to this discussion, but I need to port some of the internal code
>> to display the content of a ALE (Address Learning Engine) table maintained
>> in hardwareat L2 layer. Currently I have a sysfs implementation that dumps
>> information like below.
>>
>> root@k2e-evm:~# cat /sys/devices/platform/soc/2620110.netcp/ale_table
>> index 0, raw: 000007fc d000ffff ffffffff, type: addr(1), addr: ff:ff:ff:ff:ff:ff, mcstate: f(3), port mask: 1ff, no super
>> index 1, raw: 00000000 10000800 28329a1c, type: addr(1), addr: 08:00:28:32:9a:1c, uctype: persistent(0), port: 0
>> index 2, raw: 000007fc d0000100 5e000001, type: addr(1), addr: 01:00:5e:00:00:01, mcstate: f(3), port mask: 1ff, no super
>> index 19, raw: 00000004 d000d4be d93db6c1, type: addr(1), addr: d4:be:d9:3d:b6:c1, uctype: touched(3), port: 1
>>
>> What is the available interface in kernel to expose this information
>> to user space as debugfs is not suggested based on this thread?
> 
> This looks a lot like what the mv88e6xxx_port_fdb_dump() callback
> returns to DSA when SWITCHDEV_OBJ_ID_PORT_FDB is passed to
> switchdev_port_obj_dump() in the switchdev ops.
> 
Andrew,

Which tool user has to use to get this dump once implemented?

Murali

> 	  Andrew
> 


-- 
Murali Karicheri
Linux Kernel, Keystone
