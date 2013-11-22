From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net v3] bonding: disable arp and enable mii monitoring
 when bond change to no uses arp mode
Date: Fri, 22 Nov 2013 21:01:21 +0100
Message-ID: <528FB811.2010801@redhat.com>
References: <528710F7.7050207@huawei.com>	 <1384796682.4774.26.camel@dcbw.foobar.com>	 <20131118.154838.776189725378131169.davem@davemloft.net> <1384815032.4774.55.camel@dcbw.foobar.com> <528ACD8A.1010409@greyhouse.net> <528F6A1B.70904@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Dan Williams <dcbw@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19198 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755936Ab3KVUCc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Nov 2013 15:02:32 -0500
In-Reply-To: <528F6A1B.70904@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/22/2013 03:28 PM, Ding Tianhong wrote:
> Because the ARP monitoring is not support for 802.3ad, but I still
> could change the mode to 802.3ad from ab mode while ARP monitoring
> is running, it is incorrect.
> 
> So add a check for 802.3ad in bonding_store_mode to fix the problem,
> and make a new macro BOND_NO_USES_ARP() to simplify the code.
> 
> v2: according to the Dan Williams's suggestion, bond mode is the most
>     important bond option, it should override any of the other sub-options.
>     So when the mode is changed, the conficting values should be cleared
>     or reset, otherwise the user has to duplicate more operations to modify
>     the logic. I disable the arp and enable mii monitoring when the bond mode
>     is changed to AB, TB and 8023AD if the arp interval is true.
> 
> v3: according to the Nik's suggestion, the default value of miimon should need
>     a name, there is several place to use it, and the bond_store_arp_interval()
>     could use micro BOND_NO_USES_ARP to make the code more simpify.
> 
> Suggested-by: Dan Williams <dcbw@redhat.com>
> Suggested-by: Nikolay Aleksandrov <nikolay@redhat.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---

Reviewed-by: Nikolay Aleksandrov <nikolay@redhat.com>
