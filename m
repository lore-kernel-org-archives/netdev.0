From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: linux-next: Tree for Jan 14 (lowpan, 802.15.4)
Date: Wed, 15 Jan 2014 10:45:28 +0100
Message-ID: <20140115094527.GB12036@omega>
References: <20140114165128.0dd51f362e0f34a2ef4dc92f@canb.auug.org.au>
 <52D578A7.8020000@infradead.org>
 <CALT56yPzfkz7=WdT0p6EYXdsQJUT+Ld9gdd72z6_czn0YaKUWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Randy Dunlap <rdunlap@infradead.org>,
	"David S. Miller" <davem@davemloft.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org,
	kernel list <linux-kernel@vger.kernel.org>,
	linux-zigbee-devel <linux-zigbee-devel@lists.sourceforge.net>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jukka Rissanen <jukka.rissanen@linux.intel.com>
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALT56yPzfkz7=WdT0p6EYXdsQJUT+Ld9gdd72z6_czn0YaKUWA@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dmitry,

On Wed, Jan 15, 2014 at 02:54:56AM +0400, Dmitry Eremin-Solenikov wrote:
> Hello,
> 
> 
> On Tue, Jan 14, 2014 at 9:49 PM, Randy Dunlap <rdunlap@infradead.org> wrote:
> >
> > On 01/13/2014 09:51 PM, Stephen Rothwell wrote:
> > > Hi all,
> > >
> > > This tree fails (more than usual) the powerpc allyesconfig build.
> > >
> > > Changes since 20140113:
> > >
> >
> >
> > on i386:
> >
> > net/built-in.o: In function `header_create':
> > 6lowpan.c:(.text+0x166149): undefined reference to `lowpan_header_compress'
> > net/built-in.o: In function `bt_6lowpan_recv':
> > (.text+0x166b3c): undefined reference to `lowpan_process_data'
> 
> Ah, nice Makefile hack there.
> David, Marcel, could you please consider the attached patch.

oops, thanks for fixing this fast!

- Alex
