From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: wl1251: NVS firmware data
Date: Mon, 8 Dec 2014 16:00:18 -0500
Message-ID: <20141208210018.GB14895@kroah.com>
References: <201411271506.20457@pali>
 <201412081811.46943@pali>
 <30072B9E-2495-4F90-AC91-9C0D7E08F44E@holtmann.org>
 <201412082015.18501@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Ming Lei <ming.lei@canonical.com>, Pavel Machek <pavel@ucw.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Grazvydas Ignotas <notasas@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	Aaro Koskinen <aaro.koskinen@iki.fi>,
	Kalle Valo <kvalo@adurom.com>,
	Sebastian Reichel <sre@ring0.de>,
	David Gnedt <david.gnedt@davizone.at>
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201412082015.18501@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 08, 2014 at 08:15:18PM +0100, Pali Roh=E1r wrote:
> On Nokia N900 NVS data are generated on-the-fly from some bytes=20
> from CAL (/dev/mtd1), from state of cellular network and from=20
> some other regulation settings.

When is this "generated"?  At boot time?  Or by the firmware loader
program you have hooked into being called by the kernel at "load the
firmware now please" call time?

> So I think that files stored in linux-firmware.git tree (which=20
> are also installed into /lib/firmware/) should be loaded with=20
> request_firmware function. Or not? Do you think something else?=20
> What other developers think?
>=20
> I'm against kernel driver for CAL (/dev/mtd1) for more reasons:
>=20
> 1) we have userspace open source code, but licensed under GPLv3.=20
> And until kernel change license, we cannot include it.

You can change the license of your code if you want to, don't make this
type of nonsense argument.

> 2) NVS data are (probably) not in one place, plus they depends on=20
> something other.

What is "something other"?  Where are they located?  Why would the
firmware interface know or care anything about this?

> 3) If manufacture XYZ create new device with its own storage=20
> format of calibration data this means that correct solution for=20
> XYZ is also to implement new kernel fs driver for its own format.=20

Yes, as it is doing it's own custom thing, why overload an existing
interface to do something it was never designed to do?

> Do you really want to have in kernel all those drivers for all=20
> different (proprietary) storage formats?

Yes, we are not afraid of lots of different drivers.  That is not even =
a
valid argument, you know better than this :)

> 4) It does not help us with existence of generic file=20
> /lib/firmware/ti-connectivity/wl1251-nvs.bin which comes from=20
> linux-firmware.git tree.

Again, not an issue.  If you don't want that file in the repo, ask for
it to be removed, and it will be, just send a patch to do it.

greg k-h
