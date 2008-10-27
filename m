From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ehea: Add hugepage detection
Date: Mon, 27 Oct 2008 14:52:32 -0400
Message-ID: <49060DF0.6040607@garzik.org>
References: <200810271038.46825.tklein@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	Hannes Hering <hering2@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	netdev <netdev@vger.kernel.org>, badari@us.ibm.com,
	haveblue@us.ibm.com, tollefso@us.ibm.com
To: Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53085 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751368AbYJ0Swj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 14:52:39 -0400
In-Reply-To: <200810271038.46825.tklein@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Klein wrote:
> All kernel memory which is used for kernel/hardware data transfer must be registered
> with firmware using "memory regions". 16GB hugepages may not be part of a memory region
> due to firmware restrictions.
> This patch modifies the walk_memory_resource callback fn to filter hugepages and add
> only standard memory to the busmap which is later on used for MR registration.
> 
> Signed-off-by: Thomas Klein <tklein@de.ibm.com>
> ---
> This reworked patch accounts for comments I got. It's based on davem's net-2.6.git.

applied


