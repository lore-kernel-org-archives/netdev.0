From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [RFC] restore netdev_priv optimization
Date: Mon, 20 Aug 2007 13:51:37 +0200
Message-ID: <46C98049.7060308@bull.net>
References: <20070817154022.0f3afba4@freepuppy.rosehill.hemminger.net> <20070817.160409.88475506.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:55438 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751154AbXHTLwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 07:52:31 -0400
In-Reply-To: <20070817.160409.88475506.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

David Miller wrote:
> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Fri, 17 Aug 2007 15:40:22 -0700
> 
>> Compile tested only!!!
> 
> Obviously.  The first loopback transmit is guarenteed to crash.
> 
> [...]
> 
> And this also breaks loopback again, which uses a static struct netdev
> in the kernel image, it doesn't use alloc_netdev(), so egress_subqueue
> of loopback will be NULL.

Talking about loopback, don't you think it could be the right time
to make it behave like any other kind of net devices, and allocate it
dynamically.

Having a dynamically allocated loopback could make maintenance easier
(removing special cases).
Also this is something we'll need to support multiple loopbacks for 
example for network namespaces.

Eric Biederman has written a nice patch that does this.
I'm using it on 2.6.23-rc2.

Benjamin

-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
