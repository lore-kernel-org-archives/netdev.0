From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 1/2] e1000e: Use deferrable timer for watchdog
Date: Thu, 20 Dec 2007 13:27:34 -0800
Message-ID: <476ADE46.5020907@intel.com>
References: <20071220185125.21903.44752.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, parag.warudkar@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:39227 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754130AbXLTVc6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 16:32:58 -0500
In-Reply-To: <20071220185125.21903.44752.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auke Kok wrote:
> From: Parag Warudkar <parag.warudkar@gmail.com>
> 
> Reduce wakeups from idle per second.
> 
> Signed-off-by: Parag Warudkar <parag.warudkar@gmail.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---


Jeff,

given the discussion with Stephen I'd like to skip merging this patch and the
e1000 one for now. The unforeseen implications of this are just not controlled
enough and we need to guarantee some limit of deferral first.

Auke
