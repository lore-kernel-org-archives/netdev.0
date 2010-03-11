From: Kevin Hilman <khilman-1D3HCaltpLuhEniVeURVKkEOCMrvLtNR@public.gmane.org>
Subject: Re: [PATCH] net: davinci emac: use dma_{map,
	unmap}_single API for cache coherency
Date: Thu, 11 Mar 2010 14:56:01 -0800
Message-ID: <87eijqbh8e.fsf@deeprootsystems.com>
References: <1268133637-23399-1-git-send-email-nsekhar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: srk-l0cyMroinI0@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
To: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
In-Reply-To: <1268133637-23399-1-git-send-email-nsekhar-l0cyMroinI0@public.gmane.org> (Sekhar Nori's
	message of "Tue\, 9 Mar 2010 16\:50\:37 +0530")
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org> writes:

> The davinci emac driver uses some ARM specific DMA APIs
> for cache coherency which have been removed from kernel
> with the 2.6.34 merge.
>
> Modify the driver to use the dma_{map, unmap}_single() APIs
> defined in dma-mapping.h
>
> Without this fix, the driver fails to compile on Linus's
> tree.
>
> Tested on DM365 and OMAP-L138 EVMs.
>
> Signed-off-by: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>

Acked-by: Kevin Hilman <khilman-1D3HCaltpLuhEniVeURVKkEOCMrvLtNR@public.gmane.org>

Verified that this is compiling/running again with v2.6.34-rc1.

Kevin
