From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH resend net-next 2/3] myri10ge: Add vlan rx for better
 GRO perf.
Date: Thu, 29 Nov 2012 14:53:25 -0500
Message-ID: <50B7BD35.30909@myri.com>
References: <50B68038.5000304@myri.com>  <20121129.131738.1067398537384405805.davem@davemloft.net>  <50B7B542.6090804@myri.com> <1354218478.26201.3.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:44367 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303Ab2K2Tx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 14:53:29 -0500
Received: by mail-yh0-f46.google.com with SMTP id m54so2072895yhm.19
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 11:53:28 -0800 (PST)
In-Reply-To: <1354218478.26201.3.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/12 14:47, Joe Perches wrote:
> On Thu, 2012-11-29 at 14:19 -0500, Andrew Gallatin wrote:
>> On 11/29/12 13:17, David Miller wrote:
>>> From: Andrew Gallatin <gallatin@myri.com>
>>> Date: Wed, 28 Nov 2012 16:20:56 -0500
>>>
>>>> + if ((dev->features & (NETIF_F_HW_VLAN_RX)) == NETIF_F_HW_VLAN_RX &&
>>>> +	    (veh->h_vlan_proto == ntohs(ETH_P_8021Q))) {
>>>> +		/* fixup csum if needed */
>>>> +		if (skb->ip_summed == CHECKSUM_COMPLETE)
>>>> +			skb->csum = csum_sub(skb->csum,
>>>> + csum_partial(va + ETH_HLEN,
>>>> + VLAN_HLEN, 0));
>>>
>>> This indentation looks like spaghetti, verify that this kind of error
>>> doesn't exist in the rest of your patches, and resend the series.
>>>
>>
>> Sorry.  Emacs victim...  I'll clean it up & re-submit.  I'd stupidly
>> assumed that checkpatch would verify indentation.  :(
>
> checkpatch --strict
>

That catches one formatting error in the patch, but does not complain
about the indentation issues.

Drew
