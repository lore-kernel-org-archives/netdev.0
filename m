From: David Daney <david.daney@cavium.com>
Subject: Re: [PATCH 1/2] net: Allow skb_recycle_check to be done in stages
Date: Thu, 13 Oct 2011 08:35:00 -0700
Message-ID: <4E970524.2080908@cavium.com>
References: <1318516435-24314-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:8286 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755724Ab1JMPfB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 11:35:01 -0400
In-Reply-To: <1318516435-24314-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/13/2011 07:33 AM, Andy Fleming wrote:
> skb_recycle_check resets the skb if it's eligible for recycling.
> However, there are times when a driver might want to optionally
> manipulate the skb data with the skb before resetting the skb,
> but after it has determined eligibility.  We do this by splitting the
> eligibility check from the skb reset, creating two inline functions to
> accomplish that task.
>
> Signed-off-by: Andy Fleming<afleming@freescale.com>

Acked-by: David Daney <david.daney@cavium.com>

I need this for my (Octeon) Ethernet driver as well.  Currently we have 
an ad hoc driver local implementation of this, but I would like to use 
this core code if possible.




> ---
>
> I found this useful for a driver we're working on where the device can
> do different things, depending on whether the skb is recycleable.
>
>   include/linux/skbuff.h |   21 +++++++++++++++++++
>   net/core/skbuff.c      |   51 ++++++++++++++++++++++++-----------------------
>   2 files changed, 47 insertions(+), 25 deletions(-)
>

[...]
