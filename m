From: Rob Herring <robherring2@gmail.com>
Subject: Re: [PATCH 5/6] net: calxedaxgmac: rework transmit ring handling
Date: Fri, 12 Oct 2012 12:01:00 -0500
Message-ID: <50784CCC.3050300@gmail.com>
References: <1350054908-30646-1-git-send-email-robherring2@gmail.com>  <1350054908-30646-6-git-send-email-robherring2@gmail.com> <1350059332.2819.18.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jonathan@jonmasters.org, eric.dumazet@gmail.com,
	Mark Langsdorf <mark.langsdorf@calxeda.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1350059332.2819.18.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/12/2012 11:28 AM, Ben Hutchings wrote:
> On Fri, 2012-10-12 at 10:15 -0500, Rob Herring wrote:
>> From: Rob Herring <rob.herring@calxeda.com>
>>
>> Only generate tx interrupts on every ring size / 4 descriptors. Move the
>> netif_stop_queue call to the end of the xmit function rather than
>> checking at the beginning.
> [...]
> 
> The hardware should also interrupt if the TX ring becomes empty; does it
> do that?

Yes, with the "tx buffer unavailable" bit DMA_INTR_ENA_TUE. It is not a
per descriptor interrupt.

However, I just noticed I missed part of this patch to actually enable
tx descriptor interrupt. New version coming.

Rob
