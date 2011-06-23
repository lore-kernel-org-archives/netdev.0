From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: add min links parameter to 802.3ad
Date: Thu, 23 Jun 2011 02:13:12 -0700 (PDT)
Message-ID: <20110623.021312.91597496740233225.davem@davemloft.net>
References: <4E02452E.2030307@redhat.com>
	<20110622125439.44e47a2c@nehalam.ftrdhcpuser.net>
	<20110623015806.GO21309@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, fbl@redhat.com, fubar@us.ibm.com,
	netdev@vger.kernel.org
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52529 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758973Ab1FWJNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 05:13:31 -0400
In-Reply-To: <20110623015806.GO21309@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>
Date: Wed, 22 Jun 2011 21:58:06 -0400

> On Wed, Jun 22, 2011 at 12:54:39PM -0700, Stephen Hemminger wrote:
>> This adds support for a configuring the minimum number of links that
>> must be active before asserting carrier. It is similar to the Cisco
>> EtherChannel min-links feature. This allows setting the minimum number
>> of member ports that must be up (link-up state) before marking the
>> bond device as up (carrier on). This is useful for situations where
>> higher level services such as clustering want to ensure a minimum
>> number of low bandwidth links are active before switchover.
>> 
>> See:
>>    http://bugzilla.vyatta.com/show_bug.cgi?id=7196
>> 
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>> 
>> ---
>> v2 - need to transition to carrier_off if insufficient number of links
>>      and whitespace cleanup
>> 
> 
> Looks good.  Thanks for fixing bond_3ad_set_carrier.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

Applied, thanks everyone.
