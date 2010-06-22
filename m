From: Ben Greear <greearb@candelatech.com>
Subject: Re: Can I limit number of rx queues for igb (and other Intel drivers)?
Date: Tue, 22 Jun 2010 12:54:20 -0700
Message-ID: <4C2114EC.9040306@candelatech.com>
References: <4C1BF5AA.8010209@candelatech.com> <EDC0E76513226749BFBC9C3FB031318FD7874B40@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52026 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901Ab0FVTyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 15:54:25 -0400
In-Reply-To: <EDC0E76513226749BFBC9C3FB031318FD7874B40@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/21/2010 04:35 PM, Wyborny, Carolyn wrote:
>
>
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org
>> [mailto:netdev-owner@vger.kernel.org] On Behalf Of Ben Greear
>> Sent: Friday, June 18, 2010 3:40 PM
>> To: NetDev
>> Subject: Can I limit number of rx queues for igb (and other
>> Intel drivers)?
>>
>> I'm using pktgen to send a stream of packets with varying
>> source and destination
>> IP addresses.  It appears that the fancy rx logic of the NIC
>> (I'm using igb for this test)
>> causes the received packets to appear on random rx queues and
>> so be received out
>> of order in the network core.
>>
>> I do not see the out-of-order issue when using a single
>> source/dest IP address
>> for the pktgen packets.
>>
>> So, is there a way to tell igb to use only a single rx queue?
>>
>> Thanks,
>> Ben
>>
>> --
>> Ben Greear<greearb@candelatech.com>
>> Candela Technologies Inc  http://www.candelatech.com
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> Hello,
>
> There is not a way to tell igb to use a single queue and ethtool does not currently have a way to do this.
>
> We also maintain an out of kernel version of the driver at SourceForge that has module parameters to do this.
>
> If you need to do this with the kernel version, we'd need to modify ethtool to be able to do this.

A module parameter would be OK, but an ethtool command to change this live
would be really nice!  It may be a day or two before I get back to testing
this, but will try your out-of-tree driver with proper mod-parm invocation
then.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
