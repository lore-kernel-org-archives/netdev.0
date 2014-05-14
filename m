From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: enable interrupts in EEH resume
Date: Wed, 14 May 2014 15:37:02 -0400 (EDT)
Message-ID: <20140514.153702.1976951497745558446.davem@davemloft.net>
References: <1399969991-22762-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53702 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbaENThE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 15:37:04 -0400
In-Reply-To: <1399969991-22762-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Tue, 13 May 2014 14:03:11 +0530

> From: Kalesh AP <kalesh.purayil@emulex.com>
> 
> On some BE3 FW versions, after a HW reset, interrupts will remain disabled
> for each function. So, explicitly enable the interrupts in the eeh_resume
> handler, else after an eeh recovery interrupts wouldn't work.
> 
> Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied to 'net', thanks.
