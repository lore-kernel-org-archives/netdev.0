From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] Add ethtool -g support to 8139cp
Date: Fri, 07 Oct 2011 09:38:20 -0700
Message-ID: <4E8F2AFC.5070100@hp.com>
References: <20111005180854.3D68129003A8@tardy> <1317840648.2802.27.camel@bwh-desktop> <20111005.175329.2143609207723954863.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:14537 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965500Ab1JGQiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 12:38:22 -0400
In-Reply-To: <20111005.175329.2143609207723954863.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2011 02:53 PM, David Miller wrote:
> From: Ben Hutchings<bhutchings@solarflare.com>
> Date: Wed, 05 Oct 2011 19:50:48 +0100
>
>> You generally don't need to set fields to zero in ethtool 'get'
>> operations, as the ethtool core will initialise the entire structure to
>> zero.
>
> Rick, please remove the explicit zero initializations and resubmit,
> thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Ben/Dave

Thanks for the feedback.  I'll tweak and resend under separate cover.

rick
simply copying what he saw in e1000_get_ringparm :)
