From: Simon Horman <horms@verge.net.au>
Subject: Re: igb bandwidth allocation configuration
Date: Thu, 17 Sep 2009 11:09:35 +1000
Message-ID: <20090917010935.GA19201@verge.net.au>
References: <20090910081844.GA5421@verge.net.au>
	<15ddcffd0909140142n2a110708ld619177c65f4588b@mail.gmail.com>
	<20090915113659.GJ24194@verge.net.au>
	<4AAF963D.4060708@voltaire.com> <4AAFD690.5040900@intel.com>
	<20090915222926.GA24467@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@voltaire.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20090915222926.GA24467@verge.net.au>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Sep 16, 2009 at 08:29:26AM +1000, Simon Horman wrote:
> On Tue, Sep 15, 2009 at 11:01:52AM -0700, Alexander Duyck wrote:
> > Or Gerlitz wrote:
> > >If the rate limiter is exposed as a feature of the VF, it doesn't
> > >matter who really enforces it, the "VF portion" of the HW or the
> > >PF itself. I agree that if you have to program the PF for the rate
> > >of a specific VF, then its more complex. Basically, I would expect
> > >that a VF can be configured with <mac, vlad-id, priority, rate>
> > >such that it can be done where the VF NIC is spawned, host kernel
> > >or guest kernel.
> > 
> > Adding the rate limiter as a feature of the VF doesn't make much
> > sense since the VF could be direct assigned to another OS for all we
> > know so we won't have control over it from there.
> > 
> > The interface for all of this would make sense as part of a virtual
> > ethernet switch control which is the way I am currently leaning on
> > all this.  As such it is probably another thing we can bring up at
> > the BOF session at the Linux Plumbers Conference.
> 
> Unfortunately I won't be able to make it to the BOF or Plumbers.
> I look forward to hearing what is discussed.

Is there any chance of being able to participate in this remotely,
even just a listen-only feed of some sort would be quite valuable to me
and possibly others.

------------------------------------------------------------------------------
Come build with us! The BlackBerry&reg; Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9&#45;12, 2009. Register now&#33;
http://p.sf.net/sfu/devconf
