From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ehea: fix operation state report
Date: Thu, 03 Nov 2016 16:26:08 -0400 (EDT)
Message-ID: <20161103.162608.557887369070102192.davem@davemloft.net>
References: <1478168180-18371-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dougmill@linux.vnet.ibm.com,
        zhou@redhat.com
To: gpiccoli@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42778 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752121AbcKCU0K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 16:26:10 -0400
In-Reply-To: <1478168180-18371-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Date: Thu,  3 Nov 2016 08:16:20 -0200

> Currently the ehea driver is missing a call to netif_carrier_off()
> before the interface bring-up; this is necessary in order to
> initialize the __LINK_STATE_NOCARRIER bit in the net_device state
> field. Otherwise, we observe state UNKNOWN on "ip address" command
> output.
> 
> This patch adds a call to netif_carrier_off() on ehea's net device
> open callback.
> 
> Reported-by: Xiong Zhou <zhou@redhat.com>
> Reference-ID: IBM bz #137702, Red Hat bz #1089134
> Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>

Applied.
