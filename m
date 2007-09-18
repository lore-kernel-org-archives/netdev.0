From: "Li Yang-r58472" <LeoLi@freescale.com>
Subject: RE: [PATCH] ucc_geth: fix compilation
Date: Tue, 18 Sep 2007 16:56:18 +0800
Message-ID: <989B956029373F45A0B8AF029708189001763D1E@zch01exm26.fsl.freescale.net>
References: <20070912112456.GA15556@localhost.localdomain><20070913152333.GA2381@localhost.localdomain>
	<C844988E-F6B9-44B9-AB78-C44E19A2E605@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev <netdev@vger.kernel.org>
To: "Kumar Gala" <galak@kernel.crashing.org>, "Jeff Garzik" <jeff@garzik.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-class: urn:content-classes:message
In-Reply-To: <C844988E-F6B9-44B9-AB78-C44E19A2E605@kernel.crashing.org>
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

> -----Original Message-----
> From: linuxppc-dev-bounces+leoli=freescale.com@ozlabs.org 
> [mailto:linuxppc-dev-bounces+leoli=freescale.com@ozlabs.org] 
> On Behalf Of Kumar Gala
> Sent: Friday, September 14, 2007 10:08 PM
> To: Jeff Garzik
> Cc: linuxppc-dev@ozlabs.org list; netdev
> Subject: Re: [PATCH] ucc_geth: fix compilation
> 
> 
> On Sep 13, 2007, at 10:23 AM, Anton Vorontsov wrote:
> 
> > Currently qe_bd_t is used in the macro call -- 
> dma_unmap_single, which 
> > is a no-op on PPC32, thus error is hidden today. Starting 
> with 2.6.24, 
> > macro will be replaced by the empty static function, and 
> erroneous use 
> > of qe_bd_t will trigger compilation error.
> >
> > Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> > ---
> 
> Jeff, I'm going to pick this up via the powerpc.git tree 
> since its currently only broken in our for-2.6.24 branch 
> (because of other changes in there).  Any issues?

Kumar,

Kim Phillips has posted the same patch to netdev list before Anton.
Therefore, I do prefer to use his.  Thanks

- Leo
