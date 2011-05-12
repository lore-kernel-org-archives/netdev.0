From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 03/15] ehea: Remove force_irq logic in napi poll routine
Date: Thu, 12 May 2011 03:47:36 +0100
Message-ID: <1305168456.4065.378.camel@localhost>
References: <20110512005213.897432612@samba.org>
	 <20110512005622.766206152@samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, michael@ellerman.id.au,
	jesse@kernel.org, netdev@vger.kernel.org
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:11866 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148Ab1ELCrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2011 22:47:41 -0400
In-Reply-To: <20110512005622.766206152@samba.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-12 at 10:52 +1000, Anton Blanchard wrote:

> commit 18604c548545 (ehea: NAPI multi queue TX/RX path for SMP) added
> driver specific logic for exiting napi mode. I'm not sure what it was
> trying to solve and it should be up to the network stack to decide when
> we are done polling so remove it.
[...]

I don't know.  But I'd really like to know why you are calling
napi_reschedule() and napi_complete() in a loop, inside the poll
function.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

