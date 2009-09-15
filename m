From: Simon Horman <horms@verge.net.au>
Subject: Re: igb bandwidth allocation configuration
Date: Tue, 15 Sep 2009 21:36:59 +1000
Message-ID: <20090915113659.GJ24194@verge.net.au>
References: <20090910081844.GA5421@verge.net.au>
	<15ddcffd0909140142n2a110708ld619177c65f4588b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Or Gerlitz <ogerlitz@voltaire.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <15ddcffd0909140142n2a110708ld619177c65f4588b@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, Sep 14, 2009 at 11:42:50AM +0300, Or Gerlitz wrote:
> On 9/10/09, Simon Horman <horms@verge.net.au> wrote:
> > I have been looking into adding support the 82586's per-PF/VF bandwidth allocation to
> > the igb driver. It seems that the trickiest part is working out how to expose things to
> > user-space.
> 
> Please note that there are bunch (not many, but more then 1-2) of
> things to configure from user space in a PF/VF scheme, and I think it
> would be best if we do that through one mechanism, which may be
> netlink based or extension to ethtool as you suggested, we've started
> to discuss this on the "L2 switching in igb" thread

Thanks, I've read that thread now. I'm certainly in favour
of discussing what mechanisms make sense.

It seems to me that the main problem is that from a driver point
of view the PF and VFs are independent. But from a hardware point
of view they aren't so its not always possible for their configuration
to be independent of each other. And I'm not sure what (existing) interfaces
can handle that nicely.

> The "82576 SR-IOV Driver Companion Guide" document, section 7.6
> mentions "Transmit Bandwidth Allocation to VFs... define minimum
> transmit bandwidth for individual VMs".
> 
> I'm not clear if one can program rate limiter (upper bound) per VF or
> actually rate guarantee per VF, even  with these being  just details
> of specific device, alex, I would be happy if you can clarify that.

Its not clear to me what you are asking.


------------------------------------------------------------------------------
Come build with us! The BlackBerry&reg; Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9&#45;12, 2009. Register now&#33;
http://p.sf.net/sfu/devconf
