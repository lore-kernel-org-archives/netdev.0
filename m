From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 01/22] bnx2x: Support probing and removing
 of VF device
Date: Thu, 15 Nov 2012 15:09:54 -0500 (EST)
Message-ID: <20121115.150954.101071502783675300.davem@davemloft.net>
References: <1352998067-9707-1-git-send-email-ariele@broadcom.com>
	<1352998067-9707-2-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: ariele@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47657 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1768435Ab2KOUJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 15:09:58 -0500
In-Reply-To: <1352998067-9707-2-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ariel Elior" <ariele@broadcom.com>
Date: Thu, 15 Nov 2012 18:47:26 +0200

I'm very angry, I told you guys to fix the coding style issues in this
patch set, and you didn't even fix the class of problems I
specifically asked to be fixed.  Even the very first hunk in the very
first patch has the exact problem I said you MUST resolve.

> To support probing and removing of a bnx2x virtual function
> the following were added:
> 1. add bnx2x_vfpf.h: defines the VF to PF channel
> 2. add bnx2x_sriov.h: header for bnx2x SR-IOV functionality
> 3. enumerate VF hw types (identify VFs)
> 4. if driving a VF, map VF bar
> 5. if driving a VF, allocate Vf to PF channel
> 6. refactor interrupt flows to include VF
> 
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Please stop wasting reviewer resources, because that is what
you are doing when the very first hunk we see in a huge patch
submission is something like this:

> +enum bnx2x_int_mode {
> +	BNX2X_INT_MODE_MSIX,
> +	BNX2X_INT_MODE_INTX,
> +	BNX2X_INT_MODE_MSI
> +};
> +
> +
> +

There is no reason to have 3 blank lines here, one is more than
sufficient.

Tell me, what exactly was NOT clear in the directives I gave you for
the previous submission 2 days ago:

http://marc.info/?l=linux-netdev&m=135283453929818&w=2

I said, remove graduitous empty lines.  That's what I asked for, and
the very first first patch starts by adding gratuitous empty lines.

Re-audit this entire patch series and do not even think about
resubmitting this until such coding style problems are eliminated.

In fact, I'm going to ignore any patches you submit for the next week,
you're officially on my crap list.  Don't even think about
resubmitting this patch series until next Thursday at the earliest.
