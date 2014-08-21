From: Neil Horman <nhorman@redhat.com>
Subject: Re: [PATCH net v2] cxgb4: Fix race condition in cleanup
Date: Thu, 21 Aug 2014 07:54:01 -0400
Message-ID: <20140821115401.GB1237@hmsreliant.think-freely.org>
References: <1408567446-6598-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	hariprasad@chelsio.com, leedom@chelsio.com, svemuri@chelsio.com
To: Anish Bhatt <anish@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22708 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753955AbaHULyF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Aug 2014 07:54:05 -0400
Content-Disposition: inline
In-Reply-To: <1408567446-6598-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 20, 2014 at 01:44:06PM -0700, Anish Bhatt wrote:
> There is a possible race condition when we unregister the PCI Driver and then
> flush/destroy the global "workq". This could lead to situations where there
> are tasks on the Work Queue with references to now deleted adapter data
> structures. Instead, have per-adapter Work Queues which were instantiated and
> torn down in init_one() and remove_one(), respectively.
> 
> v2: Remove unnecessary call to flush_workqueue() before destroy_workqueue()
> 
> Signed-off-by: Anish Bhatt <anish@chelsio.com>
> Signed-off-by: Casey Leedom <leedom@chelsio.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
