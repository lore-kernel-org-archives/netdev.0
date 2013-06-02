From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v7 net-next 0/5] net: low latency Ethernet device polling
Date: Sun, 02 Jun 2013 17:02:33 +0300
Message-ID: <51AB5079.7020904@linux.intel.com>
References: <20130530114045.12653.79183.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:3895 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751722Ab3FBOCj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Jun 2013 10:02:39 -0400
In-Reply-To: <20130530114045.12653.79183.stgit@ladj378.jer.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/05/2013 14:40, Eliezer Tamir wrote:
> more fixes.
> Thank you all for your input.
>
> -Eliezer
>
> change log:
> v7
> - suggested by Ben Hutchings and Eric Dumazet:
>    type fixes, static for globals in net/core.c,
>    avoid napi_id collisions in napi_hash_add()

Dave,

Please tell my how you think I should proceed.
If you think v7 is good enough I can send a cleanup patch for the
type fixes that were suggested.
Or I can submit a v8 with those fixes.

Once we are done with what we have so far, I plan on working on adding
all the things we think are needed for a fuller implementation.
I hope to submit an RFC in a few weeks.

Thanks,
Eliezer
