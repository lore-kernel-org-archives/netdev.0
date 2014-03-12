From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 0/3] bonding: support 802.1ad vlan protocol
Date: Wed, 12 Mar 2014 16:57:21 +0800
Message-ID: <53202171.9090501@huawei.com>
References: <1394509422-8704-1-git-send-email-dingtianhong@huawei.com> <20140312061353.GA2924@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <fubar@us.ibm.com>, <andy@greyhouse.net>, <kaber@trash.net>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:41317 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbaCLI6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 04:58:55 -0400
In-Reply-To: <20140312061353.GA2924@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/3/12 14:13, Veaceslav Falico wrote:
> On Tue, Mar 11, 2014 at 11:43:39AM +0800, Ding Tianhong wrote:
>> The bonding could only use vlan proto 802.1q regardless the vlan dev is
>> 802.1ad or 802.1q, so add new interface to get vlan proto by vlan dev and
>> use it to send packages by correct vlan protocol.
> 
> It's not that easy. 802.1ad packets should be double-tagged, however you're
> just changing the protocol (from 1q to 1ad) and tagging just once.
> 
> Have you actually tested this patchset, does it produce correct QinQ
> packets?
> 

I will add test log and resend, thanks

Ding

>>
>> Ding Tianhong (3):
>>  vlan: make a new function  vlan_dev_vlan_proto() and export
>>  bonding: support different vlan proto for bond_arp_send()
>>  bonding: choose the correct vlan proto for alb_send_learning_packets
>>
>> drivers/net/bonding/bond_alb.c  |  7 ++++---
>> drivers/net/bonding/bond_main.c | 23 +++++++++++++++--------
>> include/linux/if_vlan.h         |  7 +++++++
>> net/8021q/vlan_core.c           |  6 ++++++
>> 4 files changed, 32 insertions(+), 11 deletions(-)
>>
>> -- 
>> 1.8.0
>>
>>
> 
> 
