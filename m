From: "Guy, Wey-Yi" <wey-yi.w.guy@intel.com>
Subject: Re: [PATCH] drivers/iwlwifi: use dma_zalloc_coherent() for DMA
 allocation
Date: Wed, 21 Dec 2011 08:52:10 -0800
Message-ID: <1324486330.13074.322.camel@wwguy-huron>
References: <20111221002147.GA4996@dztty>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Djalal Harouni <tixxdz@opendz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:63923 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751598Ab1LURwq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Dec 2011 12:52:46 -0500
In-Reply-To: <20111221002147.GA4996@dztty>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Djalal,


On Tue, 2011-12-20 at 16:21 -0800, Djalal Harouni wrote:
> Replace dma_alloc_coherent()+memset() with the new dma_zalloc_coherent()
> 
> Signed-off-by: Djalal Harouni <tixxdz@opendz.org>
> ---

iwl-trans-pcie.c is one of the source files in iwlwifi driver hold
dual-license (GPL + BSD), are you ok to release your code for the BSD
license and relinquish the copyright?

btw, we are in the process of rewrite and re-architect major portion of
iwlwifi driver, and we also plan to make most of the code dual-license
(GPL + BSD). 

Thanks you in advance

Wey
