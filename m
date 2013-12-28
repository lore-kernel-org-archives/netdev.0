From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v4 06/16] i40e: Implementation of VXLAN ndo's
Date: Sat, 28 Dec 2013 01:17:33 -0500 (EST)
Message-ID: <20131228.011733.510584636992289362.davem@davemloft.net>
References: <1388200940-9113-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1388200940-9113-7-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	or.gerlitz@gmail.com, joseph.gasparakis@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35142 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342Ab3L1GRf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 01:17:35 -0500
In-Reply-To: <1388200940-9113-7-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 27 Dec 2013 19:22:10 -0800

> +#ifdef CONFIG_I40E_VXLAN
> +#include "net/vxlan.h"
> +#endif

Please use <net/vxlan.h>, move this snippet into i40e.h if you have
to.
