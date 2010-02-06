From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] sky2: Allocate initial skbs in sky2_alloc_buffers
Date: Fri, 5 Feb 2010 18:10:45 -0800
Message-ID: <20100205181045.42908795@nehalam>
References: <4B6CC473.4090008@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39432 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933202Ab0BFCK5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Feb 2010 21:10:57 -0500
In-Reply-To: <4B6CC473.4090008@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 06 Feb 2010 10:22:59 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> Allocating everything in one place means there's a single point
> of failure in sky2_up, and sky2_rx_start can no longer fail.

If ring is never allocated, how then it must fail in up.
Plus if the initial ring allocation is partial it should fail.

-- 
