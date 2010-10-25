From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] Enhance AF_PACKET implementation to not require high
 order contiguous memory allocation
Date: Mon, 25 Oct 2010 22:17:07 +0200
Message-ID: <20101025201707.GA15431@electric-eye.fr.zoreil.com>
References: <1288033566-2091-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, jpirko@redhat.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 34.97.116-78.rev.gaoland.net ([78.116.97.34]:39587 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757591Ab0JYUTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 16:19:15 -0400
Content-Disposition: inline
In-Reply-To: <1288033566-2091-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nhorman@tuxdriver.com <nhorman@tuxdriver.com> :
[...]
> +		if (order > 0) {
> +			for (j = 0; j < pg_vec[i]->num_pages; j++)
> +				pages[j] = virt_to_page(pg_vec[i]->pages[j]);
> +
> +			if (unlikely(!pg_vec[i]))
> +				goto out_free_pgvec;

Check pg_vec[i] sooner ?

-- 
Ueimor
