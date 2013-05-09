From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH RFC 0/2] Control VF link state
Date: Thu, 9 May 2013 16:24:34 +0100
Message-ID: <1368113074.2653.2.camel@bwh-desktop.uk.solarflarecom.com>
References: <1368020717-22194-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <amirv@mellanox.com>,
	<ronye@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:26642 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754287Ab3EIPYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 11:24:43 -0400
In-Reply-To: <1368020717-22194-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-08 at 16:45 +0300, Or Gerlitz wrote:
> Here's a suggestion for API and implementation that lets the admin to configure
> the link state of the VF / SRIOV eSwitch vPORT. Basically, it has three states
> 
> Auto -	the VF link state will reflect the PF link state
> 
> Enable - VF link stat will be always up, traffic from VF to VF can 
> 	 work even if PF link is down.

It seems like it would be useful to implement these two options on the
PF as well.

Perhaps the default should also be specified?

Ben.

> Disable - VF link state is down and the VF can't send/recv, e.g can be 
>   	  used to suspend the link while configuring the VF.
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
