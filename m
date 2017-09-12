From: Jiri Benc <jbenc@redhat.com>
Subject: Re: Subject: [PATCH] vxlan: only reduce known arp boardcast request
 to support, virtual IP
Date: Tue, 12 Sep 2017 13:51:44 +0200
Message-ID: <20170912135144.2c83bef5@griffin>
References: <2c1bfd7d-5fe7-d492-2396-71deaeb14244@yunify.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: oc <oc@yunify.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37104 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751289AbdILLvr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 12 Sep 2017 07:51:47 -0400
In-Reply-To: <2c1bfd7d-5fe7-d492-2396-71deaeb14244@yunify.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Sep 2017 11:26:49 +0800, oc wrote:
> The purpose of vxlan arp reduce feature is to reply the boardcast
> arp request in vtep instead of sending it out to save traffic.
> The current implemention drops arp packet, if the ip cannot be
> found in neigh table. In the case of virtual IP address, user
> defines IP address without management from SDN controller. The IP
> address does not exist in neigh table, so the arp boardcast request
> from a client can not be sent to the server who owns the virtual IP
> address.
> 
> This patch allow the arp request to be sent out if:
> 1. not arp boardcast request
> 2. cannot be found in neigh table
> 3. arp record status is not NUD_CONNECTED
> 
> The user defined of virtual IP address works while arp reduce still
> suppress the arp boardcast for IP address managed by SDN controller
> with this patch.

Your patch is whitespace damaged, does not conform to the kernel coding
style and the email does not have your full name in the From header.

As for the patch itself, you're changing existing functionality that
people may depend on and thus a new config option is needed to enable
the behavior.

 Jiri
