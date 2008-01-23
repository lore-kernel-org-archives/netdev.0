From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 0/6] PS3: gelic: gelic updates for 2.6.25
Date: Tue, 22 Jan 2008 19:58:45 -0500
Message-ID: <20080123005845.GE3206@tuxdriver.com>
References: <20071213181146.BF69.MOKUNO@sm.sony.co.jp>
	<20080122211239.GC3206@tuxdriver.com>
	<1201048834.6807.55.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Geert.Uytterhoeven" <Geert.Uytterhoeven@sonycom.com>,
	netdev@vger.kernel.org, Linux/PPC Development <linuxppc-dev@ozlabs.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <1201048834.6807.55.camel@pasglop>
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

On Wed, Jan 23, 2008 at 11:40:34AM +1100, Benjamin Herrenschmidt wrote:
> 
> On Tue, 2008-01-22 at 16:12 -0500, John W. Linville wrote:
> > On Thu, Dec 13, 2007 at 07:38:28PM +0900, Masakazu Mokuno wrote:
> > 
> > > Here is a set of updates for PS3 gelic network driver.
> > > This patch set requires other patches which were already submitted by
> > > Geert (http://marc.info/?l=linux-kernel&m=119626095605487).
> > > 
> > > 	[1] PS3: gelic: Fix the wrong dev_id passed
> > > 	[2] PS3: gelic: Add endianness macros
> > > 	[3] PS3: gelic: Code cleanup
> > > 	[4] PS3: gelic: Remove duplicated ethtool handers
> > > 	[5] PS3: gelic: Add support for port link status
> > > 	[6] PS3: gelic: Add support for dual network interface
> > > 
> > > This is also a set of prerequisite for new wireless driver for PS3, which
> > > I'll submit later. 
> > 
> > These seem to not have been applied, but I couldn't find any stated
> > reason.  Did they just get lost?  Withdrawn?
> > 
> > Will these be applied?  There is a wireless patch that depends on them.
> > If not, will the wireless portion be refactored to not require these
> > patches?
> 
> The list of 6 patches above are the patches that Masakazu Mukono is
> submitting, the pre-reqs are different patches (see the linked URL),
> though I can't see them in either (they should probably go through
> paulus for-2.6.25). Geert, what's up with these ?

The wireless patch depends on the patches 1-6, which then depend on
Geert's patches.

I thought Geert's had been applied, but I guess I was looking at
it wrong.  Is there a powerpc tree that has them?  Perhaps 1-6 above
and the wireless patch should just be applied to that tree (if there
is one) and all merged together?

John
-- 
John W. Linville
linville@tuxdriver.com
