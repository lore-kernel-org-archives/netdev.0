From: Thomas Klein <osstklei@de.ibm.com>
Subject: Re: [PATCH] [2.6.27] ehea: Fix memory hotplug support
Date: Tue, 23 Sep 2008 12:33:04 +0200
Message-ID: <48D8C5E0.3060400@de.ibm.com>
References: <200809171619.46741.hannes.hering@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	ossrosch@linux.vnet.ibm.com, ossthema@de.ibm.com,
	raisch@de.ibm.com, themann@de.ibm.com
To: Hannes Hering <hannes.hering@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:59415 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855AbYIWKdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 06:33:40 -0400
In-Reply-To: <200809171619.46741.hannes.hering@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Hering wrote:
> This patch implements the memory notifier to update the busmap instantly
> instead of rebuilding the whole map. This is necessary because
> walk_memory_resource provides different information than required during memory
> hotplug.
> 
> Signed-off-by: Hannes Hering <hering2@de.ibm.com>

Jeff, please apply.

Acked-by: Thomas Klein <tklein@de.ibm.com>
