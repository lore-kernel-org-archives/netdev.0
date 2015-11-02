From: Joe Perches <joe@perches.com>
Subject: Re: [net-next v4 1/8] devres: add devm_alloc_percpu()
Date: Mon, 02 Nov 2015 11:51:32 -0800
Message-ID: <1446493892.24485.58.camel@perches.com>
References: <1446485500-9782-1-git-send-email-madalin.bucur@freescale.com>
	 <1446485500-9782-2-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	scottwood@freescale.com, igal.liberman@freescale.com,
	roy.pledge@freescale.com, ppc@mindchasers.com, pebolle@tiscali.nl,
	joakim.tjernlund@transmode.se, gregkh@linuxfoundation.org
To: madalin.bucur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0162.hostedemail.com ([216.40.44.162]:39835 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751403AbbKBTvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 14:51:38 -0500
In-Reply-To: <1446485500-9782-2-git-send-email-madalin.bucur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-11-02 at 19:31 +0200, Madalin Bucur wrote:
> Introduce managed counterparts for alloc_percpu() and free_percpu().
> Add devm_alloc_percpu() and devm_free_percpu() into the managed
> interfaces list.

trivia, could be fixed later

> +/**
> + * __devm_alloc_percpu - Resource-managed alloc_percpu
> + * @dev: Device to allocate per-cpu memory for
> + * @size: Size of per-cpu memory to allocate
> + * @align: Alignement of per-cpu memory to allocate

French spelling?  alignment
