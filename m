From: Samuel Thibault <samuel.thibault@ens-lyon.org>
Subject: Re: [PATCH] e1000: Reset rx ring index on receive
	overrun
Date: Fri, 18 May 2012 01:31:24 +0200
Message-ID: <20120517233124.GK683@type.famille.thibault.fr>
References: <20120517230140.GZ683@type.famille.thibault.fr>
	<061C8A8601E8EE4CA8D8FD6990CEA891188439E0@ORSMSX102.amr.corp.intel.com>
	<20120517232821.GJ683@type.famille.thibault.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "Dave, Tushar N" <tushar.n.dave@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>, Dean Nelson <dnelson@redhat.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20120517232821.GJ683@type.famille.thibault.fr>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Samuel Thibault, le Fri 18 May 2012 01:28:21 +0200, a =E9crit :
> Dave, Tushar N, le Thu 17 May 2012 23:22:31 +0000, a =E9crit :
> > I am interested in to see if you have actual test case and more importa=
ntly test data that shows that kernel and device indexes are not synchroniz=
ed any more.
> =

> Well, it's not with an actual physical device, but with the kvm
> emulation.

BTW, it also happens easily when request_irq takes some time to
complete: since we enable E1000_TCTL_EN before that, the card can have
time to fill the ring before irqs are processed.

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
