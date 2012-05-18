From: Samuel Thibault <samuel.thibault@ens-lyon.org>
Subject: Re: [PATCH] e1000: Reset rx ring index on receive
	overrun
Date: Fri, 18 May 2012 02:12:02 +0200
Message-ID: <20120518001202.GN683@type.famille.thibault.fr>
References: <20120517230140.GZ683@type.famille.thibault.fr>
	<061C8A8601E8EE4CA8D8FD6990CEA891188439E0@ORSMSX102.amr.corp.intel.com>
	<20120517232821.GJ683@type.famille.thibault.fr>
	<20120517233124.GK683@type.famille.thibault.fr>
	<alpine.WNT.2.00.1205171702590.7900@jbrandeb-mobl2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Jiri Pirko <jpirko@redhat.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	Dean Nelson <dnelson@redhat.com>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, "Ronciak,
	John" <john.ronciak@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <alpine.WNT.2.00.1205171702590.7900@jbrandeb-mobl2.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Brandeburg, Jesse, le Thu 17 May 2012 17:04:04 -0700, a =E9crit :
> On Thu, 17 May 2012, Samuel Thibault wrote:
> =

> > Samuel Thibault, le Fri 18 May 2012 01:28:21 +0200, a =E9crit :
> > > Dave, Tushar N, le Thu 17 May 2012 23:22:31 +0000, a =E9crit :
> > > > I am interested in to see if you have actual test case and more =

> > > > importantly test data that shows that kernel and device indexes are =

> > > > not synchronized any more.
> > > =

> > > Well, it's not with an actual physical device, but with the kvm
> > > emulation.
> > =

> > BTW, it also happens easily when request_irq takes some time to
> > complete: since we enable E1000_TCTL_EN before that, the card can have
> > time to fill the ring before irqs are processed.
> =

> I think there may well be a bug in the implementation in kvm.  The =

> hardware doesn't have this bug.

How does it avoid filling the ring?  What is the purpose of the RXO flag
if it does avoid them?

Samuel

---------------------------------------------------------------------------=
---
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and =

threat landscape has changed and how IT managers can respond. Discussions =

will include endpoint security, mobile security and the latest in malware =

threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
