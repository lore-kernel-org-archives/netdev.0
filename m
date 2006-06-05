From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2/2] e1000: remove risky prefetch on next_skb->data
Date: Mon, 05 Jun 2006 16:21:06 -0700
Message-ID: <4484BC62.3090707@hp.com>
References: <20060605230917.12584.55755.stgit@gitlost.site> <20060605231127.12584.14321.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:20678 "EHLO palrel12.hp.com")
	by vger.kernel.org with ESMTP id S1750790AbWFEXVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2006 19:21:10 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060605231127.12584.14321.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> It was brought to our attention that the prefetches break e1000 traffic
> on xscale/arm architectures.  Remove them for now.  We'll let them
> stay in mm for a while, or find a better solution to enable.

Out of curiousity, what breaks?

rick jones

