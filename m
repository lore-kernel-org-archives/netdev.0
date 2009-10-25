From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: Refactor sky2_get_regs into two functions
Date: Sun, 25 Oct 2009 09:46:46 -0700
Message-ID: <20091025094646.107f9a0a@nehalam>
References: <4AE41D88.4000100@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56724 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752338AbZJYQrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2009 12:47:00 -0400
In-Reply-To: <4AE41D88.4000100@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 25 Oct 2009 18:42:32 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> Separate code deciding which registers can be accessed out of sky2_get_regs.
> 
> Signed-off-by: Mike McCormack <mikem@ring3k.org>
> ---
>  drivers/net/sky2.c |   94 ++++++++++++++++++++++++++-------------------------
>  1 files changed, 48 insertions(+), 46 deletions(-)

Ok, but hold off applying upstream, since I have new version (support for
additional chip type), and want to not worry about patch conflict.

Acked-by: Stephen Hemminger <shemminger@vyatta.com>

-- 
