From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: Avoid races in sky2_down
Date: Thu, 16 Jul 2009 16:21:40 -0700
Message-ID: <20090716162140.20fcb1c5@nehalam>
References: <392fb48f0906200102k57f7964ah9f74c2cf40ea64b0@mail.gmail.com>
	<20090707181807.5b69a926@nehalam>
	<392fb48f0907072016i14cd650fv3524b345c79e498d@mail.gmail.com>
	<392fb48f0907112228v52624339x4f6c418ed0ee07a5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56350 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933571AbZGPXWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 19:22:04 -0400
In-Reply-To: <392fb48f0907112228v52624339x4f6c418ed0ee07a5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 12 Jul 2009 14:28:04 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> Hi Stephen,
> 
> Resending with sign off. (You may have this in your tree already, but
> just in case...)
> I ran some overnight tests with this patch in, and my machine manages
> to stay up all night, where it crashed within minutes before.
> 
> Mike
> 
> ---
> 
> Reset rx chain before trying to drain it.
> Shut interrupts off last, incase there's something to report.
> 
> Signed-off-by: Mike McCormack <mikem@ring3k.org>

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
