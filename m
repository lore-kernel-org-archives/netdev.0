From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH 4/5] pm: move pm notifiers into suspend.h
Date: Thu, 23 Jun 2011 14:04:11 +0200
Message-ID: <201106231404.12311.rjw@sisk.pl>
References: <1308724522-32461-1-git-send-email-amwang@redhat.com> <201106222149.28252.rjw@sisk.pl> <4E02C93A.7010601@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, Chris Ball <cjb@laptop.org>,
	Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>,
	"Ohad Ben-Cohen" <ohad@wizery.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	Philip Rakity <prakity@marvell.com>,
	"David S. Miller" <davem@davemloft.net>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Josh Triplett <josh@joshtriplett.org>,
	linux-mmc@vger.kernel.org, linux-pm@lists.linux-foundation.org
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <4E02C93A.7010601@redhat.com>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, June 23, 2011, Cong Wang wrote:
> =E4=BA=8E 2011=E5=B9=B406=E6=9C=8823=E6=97=A5 03:49, Rafael J. Wysock=
i =E5=86=99=E9=81=93:
> >> +#ifdef CONFIG_PM
> >> >  +#include<linux/suspend.h>
> >> >  +#endif
> > I don't think the #ifdef in necessary.  Any dependencies on CONFIG_=
PM
> > (or CONFIG_SUSPEND etc.) should be taken care of inside of suspend.=
h.
> > This file should be fixed if they aren't.
> >
>=20
> Ok, please check the updated version below.

That's fine by me.  Please feel free to add my ACK to the patch.

Thanks,
Rafael
