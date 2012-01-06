From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] drivers: misc: Remove MISC_DEVICES config option
Date: Thu, 5 Jan 2012 23:18:28 -0200
Message-ID: <CAOMZO5BQhcxViN3KnjhzF9hL1w04egkmb9njc7sDUB0GFdgBog@mail.gmail.com>
References: <1325796541-11402-1-git-send-email-festevam@gmail.com>
	<20120105223933.GA10268@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gwingerde@gmail.com,
	larry.finger@lwfinger.net, davem@davemloft.net,
	bhutchings@solarflare.com, arnd@arndb.de,
	linux-kernel@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120105223933.GA10268@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 5, 2012 at 8:39 PM, Greg KH <greg@kroah.com> wrote:

> Are you sure that this isn't getting confused with the
> drivers/char/misc.c interface instead of the "throw a bunch of random=
e
> drivers into drivers/misc/" issue?

Sorry, I am not aware of this issue.

> Why would anything ever want to select MISC_DEVICES? =C2=A0What happe=
ns if
> you just remove that select line from the Kconfig?

Yes, I don=C2=B4t understand the point of allowing the selection MISC_D=
EVICES.

IMHO it is potential for causing dependency issues.

Thanks,

=46abio Estevam
