From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net-next] can: initial support for network namespaces
Date: Thu, 16 Feb 2017 14:47:39 +0100
Message-ID: <57d4cb90-b96e-27a4-3ac5-66ebb8f1e8f4@hartkopp.net>
References: <40df4f6a-8df1-3b76-c0ed-9ba7800c2dc1@kicherer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Mario Kicherer <dev@kicherer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.221]:28965 "EHLO
        mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754693AbdBPNsw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 08:48:52 -0500
In-Reply-To: <40df4f6a-8df1-3b76-c0ed-9ba7800c2dc1@kicherer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Mario,

thanks for your patch.

On 02/16/2017 12:39 PM, Mario Kicherer wrote:
> This patch adds initial support for network namespaces. The changes only
> enable support in the CAN raw, proc and af_can code. GW and BCM still
> have their checks that ensure that they are used only from the main
> namespace.
>
> The patch boils down to moving the global structures, i.e. the global
> filter list and their /proc stats, into a per-namespace structure and passing
> around the corresponding "struct net" in a lot of different places.
>
> Signed-off-by: Mario Kicherer <dev@kicherer.org>

Although it does not apply on the latest kernel due to this patch:

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=f1712c73714088a7252d276a57126d56c7d37e64

Please rebase your patch to the latest kernel tree and post it again.

Additionally you should post CAN related stuff to the linux-can ML (see 
CC) and the CAN maintainers found in the MAINTAINERS file. In this case 
cross posting to netdev ML is fine as namespaces are very netdev related.

Do you have an idea how to go with namespace aware virtual CAN 
interfaces to link the namespaces?

Regards,
Oliver
