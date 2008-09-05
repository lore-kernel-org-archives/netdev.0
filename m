From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 2/3] ibm_newemac: Introduce mal_has_feature
Date: Fri, 05 Sep 2008 13:19:23 +1000
Message-ID: <1220584763.4879.97.camel@pasglop>
References: <cover.1220540078.git.jwboyer@linux.vnet.ibm.com>
	 <20080904150205.GC2479@yoda.jdub.homelinux.org>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:45057 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752479AbYIEDYl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2008 23:24:41 -0400
In-Reply-To: <20080904150205.GC2479@yoda.jdub.homelinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-09-04 at 11:02 -0400, Josh Boyer wrote:
> There are some PowerPC SoCs that do odd things with the MAL handling.  In
> order to accommodate them, we need to introduce a feature mechanism that is
> similar to the existing emac_has_feature function.
> 
> This adds a feature variable to the mal_instance structure, and adds a
> mal_has_feature function with some feature definitions.  These are guarded
> by Kconfig options that are selected by the affected platforms.
> 
> Signed-of-by: Josh Boyer <jwboyer@linux.vnet.ibm.com>

You also add an actual feature (CLR_ICINSTAT). You should document that
or move it to a separate patch.

> +/* Features of various MAL implementations */
> +
> +/* Dummy feature bit so the enum works properly */
> +#define MAL_FTR_DUMMY	0x00000001

Nah. Just stick an | 0 in the enum to make it happy.

Cheers,
Ben.


