From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH 2/2] Driver core: reduce duplicated code
Date: Tue, 15 Jun 2010 11:05:00 +0200
Message-ID: <20100615090500.GA17595@pengutronix.de>
References: <1276591677-4678-1-git-send-email-u.kleine-koenig@pengutronix.de> <1276591677-4678-2-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Magnus Damm <damm@opensource.se>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Paul Mundt <lethal@linux-sh.org>,
	Dmitry Torokhov <dtor@mail.ru>,
	Eric Miao <eric.y.miao@gmail.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1276591677-4678-2-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Tue, Jun 15, 2010 at 10:47:56AM +0200, Uwe Kleine-K=F6nig wrote:
> This makes the two similar functions platform_device_register_simple
> and platform_device_register_data one line inline functions using a n=
ew
> generic function platform_device_register_resndata.
I forgot to add some comments to this mail, ... sorry.

 - I'm not completely happy with the name of the new function.  If
   someone has a better name please tell me.
 - can platform_device_register_resndata be moved to __init_or_module?
 - I moved the kernel docs to the header but didn't test if they are
   picked up when generating docs.  Even if not, there is no better
   place, is there?

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
