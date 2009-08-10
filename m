From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: Create buffer alloc and free helpers
Date: Mon, 10 Aug 2009 08:29:43 -0700
Message-ID: <20090810082943.3d389e8a@nehalam>
References: <4A7EB5A0.3040401@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44089 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753575AbZHJP37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 11:29:59 -0400
In-Reply-To: <4A7EB5A0.3040401@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 09 Aug 2009 20:40:16 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> Refactor similar two sections of code that free buffers into one.
> As a side effect, only call tx_init() in sky2_up() if all buffer 
>  allocations succeed.
> 
> Signed-off-by: Mike McCormack <mikem@ring3k.org>

> +	if (0 > sky2_alloc_buffers(sky2))
>  		goto err_out;

Don't change code style. Especially in mid driver.

Just return 0 for success and errno or -1.
