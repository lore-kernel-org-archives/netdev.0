From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] igbvf: clear buffer_info->dma after
	dma_unmap_single()
Date: Thu, 6 Aug 2015 17:16:31 +0000
Message-ID: <253CF818969A9240AB2054BF91F2C2BC3017DE59@ORSMSX114.amr.corp.intel.com>
References: <1438846337-6164-1-git-send-email-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stefan Assmann <sassmann@kpanic.de>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:37180 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754486AbbHFRQc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 13:16:32 -0400
In-Reply-To: <1438846337-6164-1-git-send-email-sassmann@kpanic.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 6 Aug 2015 09:32:17 +0200
Stefan Assmann <sassmann@kpanic.de> wrote:

> The driver doesn't clear buffer_info->dma after calling
> dma_unmap_single() in all cases. This has been discovered by changing
> the mtu twice, which caused the following backtrace.

should be for NET?

Looks good, thanks Stefan!

Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
