From: Ming Lei <ming.lei@canonical.com>
Subject: Re: wl1251: NVS firmware data
Date: Thu, 27 Nov 2014 23:34:47 +0800
Message-ID: <CACVXFVMMpY_99NrhLXeY-PMBFFACZxaE4hsq0+gff0YzHmeywg@mail.gmail.com>
References: <201411271506.20457@pali>
	<201411271543.23527@pali>
	<20141127151448.GA23064@kroah.com>
	<201411271624.03066@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
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
To: =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201411271624.03066@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 27, 2014 at 11:24 PM, Pali Roh=C3=A1r <pali.rohar@gmail.com=
> wrote:
> On Thursday 27 November 2014 16:14:48 Greg Kroah-Hartman wrote:
>> On Thu, Nov 27, 2014 at 03:43:23PM +0100, Pali Roh=C3=A1r wrote:
>> > Which userspace helper programs for (automatic) firmware
>> > loading are used? Can be udev configured to use own program
>> > for loading firmware instead that udev integrated which
>> > looking for firmware only in /lib/firmware files?
>>
>> The code to load firmware from userspace has been removed from
>> udev, so that's not going to work at all, sorry.
>>
>> greg k-h
>
> Ok and how to load (dynamic) firmware files into kernel? What is
> preferred way if not udev (because it removed that support)?

As I said, it isn't difficult to write a helper with uevent monitor for
your case, and you can refer to mdev or android's implementation.

Thanks,
Ming Lei
