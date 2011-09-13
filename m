From: Lin Ming <ming.m.lin@intel.com>
Subject: Re: [PATCH -v2] netconsole: switch init_netconsole() to
 late_initcall if build-in
Date: Tue, 13 Sep 2011 16:26:53 +0800
Message-ID: <1315902413.6346.0.camel@snb>
References: <1315899939.3402.2.camel@snb>
	 <CAM_iQpVsKXn3ZMygOKc699KQPXbt=-yEWMdKFLqYGVucoJ874w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpVsKXn3ZMygOKc699KQPXbt=-yEWMdKFLqYGVucoJ874w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-09-13 at 15:55 +0800, Am=C3=A9rico Wang wrote:
> On Tue, Sep 13, 2011 at 3:45 PM, Lin Ming <ming.m.lin@intel.com> wrot=
e:
> > Commit 88491d8(drivers/net: Kconfig & Makefile cleanup) causes a
> > regression that netconsole does not work if netconsole and network
> > device driver are build into kernel, because netconsole is linked
> > before network device driver.
> >
> > Andrew Morton suggested to fix this with initcall ordering.
> > Fixes it by switching init_netconsole() to late_initcall if build-i=
n.
> >
>=20
> Putting one or two lines of comments into the code would
> be nicer, otherwise people have to dig git log to see why. ;-)

Will add.

Thanks.
