From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] drivers: misc: Remove MISC_DEVICES config option
Date: Thu, 5 Jan 2012 21:03:55 -0800
Message-ID: <20120106050355.GA7633@kroah.com>
References: <1325796541-11402-1-git-send-email-festevam@gmail.com>
 <20120105223933.GA10268@kroah.com>
 <CAOMZO5BQhcxViN3KnjhzF9hL1w04egkmb9njc7sDUB0GFdgBog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gwingerde@gmail.com,
	larry.finger@lwfinger.net, davem@davemloft.net,
	bhutchings@solarflare.com, arnd@arndb.de,
	linux-kernel@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAOMZO5BQhcxViN3KnjhzF9hL1w04egkmb9njc7sDUB0GFdgBog@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 05, 2012 at 11:18:28PM -0200, Fabio Estevam wrote:
> On Thu, Jan 5, 2012 at 8:39 PM, Greg KH <greg@kroah.com> wrote:
>=20
> > Are you sure that this isn't getting confused with the
> > drivers/char/misc.c interface instead of the "throw a bunch of rand=
ome
> > drivers into drivers/misc/" issue?
>=20
> Sorry, I am not aware of this issue.
>=20
> > Why would anything ever want to select MISC_DEVICES? =A0What happen=
s if
> > you just remove that select line from the Kconfig?
>=20
> Yes, I don=B4t understand the point of allowing the selection MISC_DE=
VICES.
>=20
> IMHO it is potential for causing dependency issues.

Then remove that selection.  Nothing should be depending on a misc
driver, if it is, then that implies that this is more than just a "misc=
"
driver, and it should be moved elsewhere.

thanks,

greg k-h
