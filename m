From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: wl1251: NVS firmware data
Date: Thu, 27 Nov 2014 07:14:48 -0800
Message-ID: <20141127151448.GA23064@kroah.com>
References: <201411271506.20457@pali>
 <CACVXFVMr8jH1ZzyPNG91VDK8DuVjQsHn9ks62sSNjOfUnNsURQ@mail.gmail.com>
 <201411271543.23527@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ming Lei <ming.lei@canonical.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Grazvydas Ignotas <notasas@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Pavel Machek <pavel@ucw.cz>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	Aaro Koskinen <aaro.koskinen@iki.fi>,
	Kalle Valo <kvalo@adurom.com>,
	Sebastian Reichel <sre@ring0.de>,
	David Gnedt <david.gnedt@davizone.at>
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201411271543.23527@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 27, 2014 at 03:43:23PM +0100, Pali Roh=E1r wrote:
> Which userspace helper programs for (automatic) firmware loading=20
> are used? Can be udev configured to use own program for loading=20
> firmware instead that udev integrated which looking for firmware=20
> only in /lib/firmware files?

The code to load firmware from userspace has been removed from udev, so
that's not going to work at all, sorry.

greg k-h
