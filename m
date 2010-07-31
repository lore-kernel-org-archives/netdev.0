From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] TI DaVinci EMAC: Fix asymmetric handling of
 packets in NAPI Poll function.
Date: Fri, 30 Jul 2010 23:56:19 -0700 (PDT)
Message-ID: <20100730.235619.102547507.davem@davemloft.net>
References: <1280406840-27393-1-git-send-email-srk@ti.com>
	<1280406840-27393-2-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com, nsekhar@ti.com,
	anantgole@ti.com
To: srk@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41322
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751449Ab0GaG4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jul 2010 02:56:02 -0400
In-Reply-To: <1280406840-27393-2-git-send-email-srk@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sriramakrishnan <srk@ti.com>
Date: Thu, 29 Jul 2010 18:03:59 +0530

> The current implementation of NAPI poll function in the driver does not service
> Rx packets, error condition even if a single Tx packet gets serviced in
> the napi poll call. This behavior severely affects performance for specific use
> cases. This patch modifies the poll function implementation to service tx/rx
> packets in an identical manner.
> 
> Signed-off-by: Sriramakrishnan <srk@ti.com>

Applied.
