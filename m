From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Wed, 13 Aug 2008 15:29:55 -0400
Message-ID: <48A33633.20800@pobox.com>
References: <adad4kfxm9v.fsf@cisco.com> <200808121457.11356.divy@chelsio.com> <20080812.150246.42068558.davem@davemloft.net> <200808121521.10101.divy@chelsio.com> <48A32976.7060504@vlnb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, open-iscsi@googlegroups.com,
	rdreier@cisco.com, rick.jones2@hp.com,
	Steve Wise <swise@opengridcomputing.com>,
	Karen Xie <kxie@chelsio.com>, netdev@vger.kernel.org,
	michaelc@cs.wisc.edu, daisyc@us.ibm.com, wenxiong@us.ibm.com,
	bhua@us.ibm.com, Dimitrios Michailidis <dm@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vladislav Bolkhovitin <vst@vlnb.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58767 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752464AbYHMTaQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 15:30:16 -0400
In-Reply-To: <48A32976.7060504@vlnb.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vladislav Bolkhovitin wrote:
> Divy Le Ray wrote:
>> On Tuesday 12 August 2008 03:02:46 pm David Miller wrote:
>>> From: Divy Le Ray <divy@chelsio.com>
>>> Date: Tue, 12 Aug 2008 14:57:09 -0700
>>>
>>>> In any case, such a stateless solution is not yet designed, whereas
>>>> accelerated iSCSI is available now, from us and other companies.
>>> So, WHAT?!
>>>
>>> There are TOE pieces of crap out there too.
>>
>> Well, there is demand for accerated iscsi out there, which is the 
>> driving reason of our driver submission. 
> 
> I'm, as an iSCSI target developer, strongly voting for hardware iSCSI 
> offload. Having possibility of the direct data placement is a *HUGE* 
> performance gain.

Well, two responses here:

* no one is arguing against hardware iSCSI offload.  Rather, it is a 
problem with a specific implementation, one that falsely assumes two 
independent TCP stacks can co-exist peacefully on the same IP address 
and MAC.

* direct data placement is possible without offloading the entire TCP 
stack onto a firmware/chip.

There is plenty of room for hardware iSCSI offload...

	Jeff


