From: Sven Luther <sven@powerlinux.fr>
Subject: Re: [PATCH] pegasos_eth.c: Fix compile error over MV643XX_ defines
Date: Tue, 30 Oct 2007 10:36:06 +0100
Message-ID: <20071030093606.GA20920@powerlinux.fr>
References: <20071029212729.GA4074@pogo>
	<20071029223900.GA7097@xyzzy.farnsworth.org>
	<43e72e890710300044o60bfc46cv8815226e39634996@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tzachi Perelstein <tzachi@marvell.com>, Jeff Garzik <jeff@garzik.org>,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <43e72e890710300044o60bfc46cv8815226e39634996@mail.gmail.com>
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

On Tue, Oct 30, 2007 at 03:44:59AM -0400, Luis R. Rodriguez wrote:
> On 10/29/07, Dale Farnsworth <dale@farnsworth.org> wrote:
> > On Mon, Oct 29, 2007 at 05:27:29PM -0400, Luis R. Rodriguez wrote:
> > > This commit made an incorrect assumption:
> > > --
> > > Author: Lennert Buytenhek <buytenh@wantstofly.org>
> > >  Date:   Fri Oct 19 04:10:10 2007 +0200
> > >
> > >     mv643xx_eth: Move ethernet register definitions into private header
> > >
> > >     Move the mv643xx's ethernet-related register definitions from
> > >     include/linux/mv643xx.h into drivers/net/mv643xx_eth.h, since
> > >     they aren't of any use outside the ethernet driver.
> > >
> > >     Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> > >     Acked-by: Tzachi Perelstein <tzachi@marvell.com>
> > >     Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
> > > --
> > >
> > > arch/powerpc/platforms/chrp/pegasos_eth.c made use of a 3 defines there.
> > >
> > > mcgrof@pogo:~/devel/wireless-2.6$ git-describe
> > >
> > > v2.6.24-rc1-138-g0119130
> > >
> > > This patch fixes this by internalizing 3 defines onto pegasos which are
> > > simply no longer available elsewhere. Without this your compile will fail
> >
> > That compile failure was fixed in commit
> > 30e69bf4cce16d4c2dcfd629a60fcd8e1aba9fee by Al Viro.
> >
> > However, as I examine that commit, I see that it defines offsets from
> > the eth block in the chip, rather than the full chip registeri block
> > as the Pegasos 2 code expects.  So, I think it fixes the compile
> > failure, but leaves the Pegasos 2 broken.
> >
> > Luis, do you have Pegasos 2 hardware?  Can you (or anyone) verify that
> > the following patch is needed for the Pegasos 2?
> 
> Nope, sorry.

I am busy right now, but have various pegasos machines available for
testing. What exactly should i test ? 

Friendly,

Sven Luther
