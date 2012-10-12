From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 5/6] net: calxedaxgmac: rework transmit ring handling
Date: Fri, 12 Oct 2012 17:28:52 +0100
Message-ID: <1350059332.2819.18.camel@bwh-desktop.uk.solarflarecom.com>
References: <1350054908-30646-1-git-send-email-robherring2@gmail.com>
	 <1350054908-30646-6-git-send-email-robherring2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<jonathan@jonmasters.org>, <eric.dumazet@gmail.com>,
	Mark Langsdorf <mark.langsdorf@calxeda.com>,
	Rob Herring <rob.herring@calxeda.com>
To: Rob Herring <robherring2@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1350054908-30646-6-git-send-email-robherring2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-10-12 at 10:15 -0500, Rob Herring wrote:
> From: Rob Herring <rob.herring@calxeda.com>
> 
> Only generate tx interrupts on every ring size / 4 descriptors. Move the
> netif_stop_queue call to the end of the xmit function rather than
> checking at the beginning.
[...]

The hardware should also interrupt if the TX ring becomes empty; does it
do that?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
