From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] kill massive wireless-related log spam
Date: Wed, 26 Oct 2005 11:42:51 -0400
Message-ID: <435FA3FB.9030107@pobox.com>
References: <20051026042827.GA22836@havoc.gtf.org> <200510261704.15366.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@osdl.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jketreno@linux.intel.com,
	Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964792AbVJZPnF@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200510261704.15366.ak@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> On Wednesday 26 October 2005 06:28, Jeff Garzik wrote:
> 
> 
>>Change this to printing out the message once, per kernel boot.
> 
> 
> It doesn't do that. It prints it once every 2^32 calls. Also

...which is effectively one per kernel boot


> the ++ causes unnecessary dirty cache lines in normal operation.

Not a hot path operation by any stretch of the imagination, so that's fine.

	Jeff
