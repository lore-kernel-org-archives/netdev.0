From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ioat/dca: Update DCA BIOS workarounds to use
 TAINT_FIRMWARE_WORKAROUND
Date: Fri, 22 Mar 2013 12:56:06 -0400 (EDT)
Message-ID: <20130322.125606.2149685007701615897.davem@davemloft.net>
References: <20130322155407.14605.67885.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	gospo@redhat.com, david.woodhouse@intel.com, sassmann@redhat.com,
	jeffrey.t.kirsher@intel.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51656 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161000Ab3CVQ4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 12:56:09 -0400
In-Reply-To: <20130322155407.14605.67885.stgit@ahduyck-cp1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Fri, 22 Mar 2013 09:01:59 -0700

> This patch is meant to be a follow-up for a patch originally submitted under
> the title "ioat: Do not enable DCA if tag map is invalid".  It was brought to
> my attention that the preferred approach for BIOS workarounds is to set the
> taint flag for TAINT_FIRMWARE_WORKAROUND for systems that require BIOS
> workarounds.
> 
> This change makes it so that the DCA workarounds for broken BIOSes will now
> use WARN_TAINT_ONCE(1, TAINT_FIRMWARE_WORKAROUND, ...) instead of just
> printing a message via dev_err.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Applied, thanks Alex.
