From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ehea: Fix memory hotplug support
Date: Tue, 21 Oct 2008 02:11:22 -0400
Message-ID: <48FD728A.2090504@garzik.org>
References: <200809171619.46741.hannes.hering@linux.vnet.ibm.com> <200810151318.59151.hannes.hering@linux.vnet.ibm.com> <48F7056F.7050602@garzik.org> <200810161136.42822.hannes.hering@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, ossrosch@linux.vnet.ibm.com,
	ossthema@de.ibm.com, raisch@de.ibm.com, themann@de.ibm.com,
	osstklei@de.ibm.com
To: Hannes Hering <hannes.hering@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46205 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753573AbYJUGL1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 02:11:27 -0400
In-Reply-To: <200810161136.42822.hannes.hering@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Hering wrote:
> This patch implements the memory notifier to update the busmap instantly
> instead of rebuilding the whole map. This is necessary because
> walk_memory_resource provides different information than required during memory
> hotplug.
> 
> Signed-off-by: Hannes Hering <hering2@de.ibm.com>
> ---
> Jeff, as requested, this patch is now based on davem's net-2.6.git.

applied


