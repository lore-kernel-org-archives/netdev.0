From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: Add ndo_gso_check
Date: Wed, 15 Oct 2014 12:11:16 -0400 (EDT)
Message-ID: <20141015.121116.1805243151246641620.davem@davemloft.net>
References: <1413325146-2404-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52077 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020AbaJOQLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 12:11:18 -0400
In-Reply-To: <1413325146-2404-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 14 Oct 2014 15:19:06 -0700

> Add ndo_gso_check which a device can define to indicate whether is
> is capable of doing GSO on a packet. This funciton would be called from
> the stack to determine whether software GSO is needed to be done. A
> driver should populate this function if it advertises GSO types for
> which there are combinations that it wouldn't be able to handle. For
> instance a device that performs UDP tunneling might only implement
> support for transparent Ethernet bridging type of inner packets
> or might have limitations on lengths of inner headers.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied, thanks Tom.
