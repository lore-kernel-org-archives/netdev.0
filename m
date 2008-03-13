From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH] ibm_newemac: emac_tx_csum typo fix.patch
Date: Thu, 13 Mar 2008 16:42:47 +0100
Message-ID: <200803131642.47920.sr@denx.de>
References: <20080222192139.GA26126@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linuxppc-dev@ozlabs.org,
 netdev@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20080222192139.GA26126@ru.mvista.com>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Friday 22 February 2008, Valentine Barshak wrote:
> Move the "&& skb->ip_summed == CHECKSUM_PARTIAL" part out of
> emac_has_feature parameters.
>
> Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>

Acked-by: Stefan Roese <sr@denx.de>

I think this is 2.6.25 material. I just stumbled over this problem too while 
enabling TAH on 440GX and 460EX/GT.

Thanks.

Best regards,
Stefan
