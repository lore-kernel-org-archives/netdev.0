From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: calxedaxgmac: rework transmit ring handling
Date: Fri, 12 Oct 2012 20:30:20 +0200
Message-ID: <1350066620.21172.12996.camel@edumazet-glaptop>
References: <1350054908-30646-6-git-send-email-robherring2@gmail.com>
	 <1350065099-32649-1-git-send-email-robherring2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jonathan@jonmasters.org,
	Mark Langsdorf <mark.langsdorf@calxeda.com>,
	Rob Herring <rob.herring@calxeda.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Rob Herring <robherring2@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1350065099-32649-1-git-send-email-robherring2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-10-12 at 13:04 -0500, Rob Herring wrote:
> From: Rob Herring <rob.herring@calxeda.com>
> 
> Only generate tx interrupts on every ring size / 4 descriptors. Move the
> netif_stop_queue call to the end of the xmit function rather than
> checking at the beginning.
> 
> Signed-off-by: Rob Herring <rob.herring@calxeda.com>
> ---
> v2:
> - Add missed enabling of the descriptor tx interrupt

Seems to be net-next material to me.

Furthermore, your changelog is a bit terse for such a patch, that could
easily break upper layers.

You need to tell us how long TX completion for a packet might be
deferred.

Thanks
