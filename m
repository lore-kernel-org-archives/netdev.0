From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH resend net-next 2/3] myri10ge: Add vlan rx for better
 GRO perf.
Date: Thu, 29 Nov 2012 14:19:30 -0500
Message-ID: <50B7B542.6090804@myri.com>
References: <50B68038.5000304@myri.com> <20121129.131738.1067398537384405805.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:38798 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753554Ab2K2TTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 14:19:34 -0500
Received: by mail-gh0-f174.google.com with SMTP id g15so2581387ghb.19
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 11:19:34 -0800 (PST)
In-Reply-To: <20121129.131738.1067398537384405805.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/12 13:17, David Miller wrote:
> From: Andrew Gallatin <gallatin@myri.com>
> Date: Wed, 28 Nov 2012 16:20:56 -0500
>
>> + if ((dev->features & (NETIF_F_HW_VLAN_RX)) == NETIF_F_HW_VLAN_RX &&
>> +	    (veh->h_vlan_proto == ntohs(ETH_P_8021Q))) {
>> +		/* fixup csum if needed */
>> +		if (skb->ip_summed == CHECKSUM_COMPLETE)
>> +			skb->csum = csum_sub(skb->csum,
>> + csum_partial(va + ETH_HLEN,
>> + VLAN_HLEN, 0));
>
> This indentation looks like spaghetti, verify that this kind of error
> doesn't exist in the rest of your patches, and resend the series.
>

Sorry.  Emacs victim...  I'll clean it up & re-submit.  I'd stupidly
assumed that checkpatch would verify indentation.  :(

Drew
