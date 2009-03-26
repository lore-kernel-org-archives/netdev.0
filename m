From: Patrick McHardy <kaber@trash.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Thu, 26 Mar 2009 16:08:07 +0100
Message-ID: <49CB9A57.6030903@trash.net>
References: <20090326141405.GA25404@ioremap.net> <49CB8EC6.6070705@trash.net> <20090326145946.GA28563@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34125 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760AbZCZPIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 11:08:19 -0400
In-Reply-To: <20090326145946.GA28563@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov wrote:
> On Thu, Mar 26, 2009 at 03:18:46PM +0100, Patrick McHardy (kaber@trash.net) wrote:
>> Evgeniy Polyakov wrote:
>>> +static void xt_osf_send_connector(const struct xt_osf_user_finger *f,
>>> +				   const struct sk_buff *skb)
>>> +{
>>> +#if 1
>>> +	return;
>>> +#else
>> Please get rid of the connector remains.
>>
>> The decision whether to still merge it in this window is up to Dave.
>> I already have some late-comers queued up that I hope to still get
>> in and I don't want to unnecessarily decrease my chances :)
> 
> I left that chunk to the case when we will want to send notifications to
> the userspace, right now we do not , so it is commented. And yes, names
> were not changed :)

nfnetlink also supports notifications. Please get rid of this,
it should be no problem to resurrect the necessary parts later
if this is desired.

> If Dave will refuse to pull it, please queue it into the netfilter tree
> for the next merge window update, since I will miss it almost for sure.

Will do.


