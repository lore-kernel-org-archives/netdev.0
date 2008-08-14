From: Vladislav Bolkhovitin <vst@vlnb.net>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Thu, 14 Aug 2008 22:30:11 +0400
Message-ID: <48A479B3.40609@vlnb.net>
References: <20080812.150246.42068558.davem@davemloft.net>	<200808121521.10101.divy@chelsio.com>	<48A32976.7060504@vlnb.net> <20080813.132319.175666454.davem@davemloft.net> <48A47925.3000409@vlnb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: open-iscsi@googlegroups.com, rdreier@cisco.com, rick.jones2@hp.com,
	jgarzik@pobox.com, swise@opengridcomputing.com, kxie@chelsio.com,
	netdev@vger.kernel.org, michaelc@cs.wisc.edu, daisyc@us.ibm.com,
	wenxiong@us.ibm.com, bhua@us.ibm.com, dm@chelsio.com,
	leedom@chelsio.com, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <48A47925.3000409@vlnb.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vladislav Bolkhovitin wrote:
> David Miller wrote:
>> From: Vladislav Bolkhovitin <vst@vlnb.net>
>> Date: Wed, 13 Aug 2008 22:35:34 +0400
>>
>>> This is because the target sends data in a zero-copy manner, so its
>>> CPU is capable to deal with the load, but on the initiator there are
>>> additional data copies from skb's to page cache and from page cache
>>> to application.
>> If you've actually been reading at all what I've been saying in this
>> thread you'll see that I've described a method to do this copy
>> avoidance in a completely stateless manner.
>>
>> You don't need to implement a TCP stack in the card in order to do
>> data placement optimizations.  They can be done completely stateless.
> 
> Sure, I read what you wrote before writing (although, frankly, didn't 
> get the idea). But I don't think that overall it would be as efficient 
> as full hardware offload. See my reply to Jeff Garzik about that.
> 
>> Also, large portions of the cpu overhead are transactional costs,
>> which are significantly reduced by existing technologies such as
>> LRO.
> 
> The test used Myricom Myri-10G cards (myri10ge driver), which support 
> LRO. And from ethtool -S output I conclude it was enabled. Just in case, 
> I attached it, so you can recheck me.

Also, there wasn't big difference between MTU 1500 and 9000, which is 
another point to think that LRO was working.

> Thus, apparently, LRO doesn't make a fundamental difference. Maybe this 
> particular implementation isn't too efficient, I don't know. I don't 
> have enough information for that.
> 
> Vlad
> 
> 

