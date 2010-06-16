From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 2/2] Driver core: reduce duplicated code
Date: Wed, 16 Jun 2010 13:53:32 -0700
Message-ID: <20100616205332.GB15837@kroah.com>
References: <1276591677-4678-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <1276591677-4678-2-git-send-email-u.kleine-koenig@pengutronix.de>
 <20100615090500.GA17595@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>,
	Magnus Damm <damm@opensource.se>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Paul Mundt <lethal@linux-sh.org>,
	Dmitry Torokhov <dtor@mail.ru>,
	Eric Miao <eric.y.miao@gmail.com>, netdev@vger.kernel.org
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100615090500.GA17595@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 15, 2010 at 11:05:00AM +0200, Uwe Kleine-K=F6nig wrote:
> Hello,
>=20
> On Tue, Jun 15, 2010 at 10:47:56AM +0200, Uwe Kleine-K=F6nig wrote:
> > This makes the two similar functions platform_device_register_simpl=
e
> > and platform_device_register_data one line inline functions using a=
 new
> > generic function platform_device_register_resndata.
> I forgot to add some comments to this mail, ... sorry.
>=20
>  - I'm not completely happy with the name of the new function.  If
>    someone has a better name please tell me.

I don't like it either, what is "resndata" supposed to stand for?

>  - can platform_device_register_resndata be moved to __init_or_module=
?

I doubt it, but try it and see if a build warns about it.

>  - I moved the kernel docs to the header but didn't test if they are
>    picked up when generating docs.  Even if not, there is no better
>    place, is there?

No, that's the proper place, but make sure the docbook source is also
picking up the .h file, I don't know if it currently does.

So, I'll not apply this one just yet.  Can you verify the docbook stuff
at the very least?

thanks,

greg k-h
