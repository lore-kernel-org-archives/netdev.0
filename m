From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next] bonding: move the netdev_add_tso_features()
 to bonding module
Date: Sun, 19 Jan 2014 13:34:21 +0800
Message-ID: <52DB63DD.50203@huawei.com>
References: <52DA3BE5.5020500@huawei.com>	 <20140118114801.GA30549@redhat.com> <1390064923.31367.531.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:25204 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739AbaASFe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 00:34:59 -0500
In-Reply-To: <1390064923.31367.531.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/19 1:08, Eric Dumazet wrote:
> On Sat, 2014-01-18 at 12:48 +0100, Veaceslav Falico wrote:
>> On Sat, Jan 18, 2014 at 04:31:33PM +0800, Ding Tianhong wrote:
>>> The function netdev_add_tso_features() was only be used for bonding,
>>> so no need to export it in netdevice.h, move it to bonding module.
>>
>> Eric added it for a reason - like, other drivers might use it. Do you know
>> if team, bridge, vlan etc. might use it?
> 
> A helper can be used once, this is fine. A car can have 4 seats, and can
> even be used with no passenger.
> 
> I am quite bored by patches that break clean layering for wrong reasons.
> 
> 
> static inline netdev_features_t netdev_add_tso_features(netdev_features_t features,
>                                                       netdev_features_t mask)
> {
>       return netdev_increment_features(features, NETIF_F_ALL_TSO, mask);
> }
> 
> There is _nothing_ in this helper that implies it should be private to bonding.
> 
> 

yep, it is look so fool that my patch said, thanks for reminding me.

> 
> 
> 
