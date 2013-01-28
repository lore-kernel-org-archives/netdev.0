From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH, resubmit] ax88179_178a: ASIX AX88179_178A USB 3.0/2.0 to gigabit ethernet adapter driver
Date: Mon, 28 Jan 2013 10:07:32 +0100
Message-ID: <87zjztptez.fsf@nemi.mork.no>
References: <1358908337-13841-1-git-send-email-freddy@asix.com.tw>
	<20130127001347.584711b2@xenia>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Freddy Xin <freddy@asix.com.tw>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	louis@asix.com.tw, davem@davemloft.net, Support@asix.com.tw
To: Michael Leun <lkml20130126@newton.leun.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130127001347.584711b2@xenia> (Michael Leun's message of "Sun,
	27 Jan 2013 00:13:47 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Michael,

Michael Leun <lkml20130126@newton.leun.net> writes:

> I would vote to not accept that driver for mainline as long as this
> issues are not fixed.=20
>
> The vendor should not be able to claim "hooray, hooray, great device,
> we even have an driver in linux main line" when it is actually such a=
n
> useless crap.

Well, that is fortunately not how these things work. The main goal is
getting the devices supported in the kernel. Bugs can be fixed.  If a
vendor can get any positive gain out of having a driver in mainline,
then that is good for everyone, isn't it?  Of course, we can all agree
that the effect of a *working* driver is more positive than a
non-working driver...

=46or now, the main focus should be fixing the issues which has been no=
ted
during review.  Your testing feedback is of course very useful, but you
probably need to back them up with actual code change proposals if they
are going to be dealt with at this stage.

> Of course I'm offering to help with any information or testing, but
> unfortunately I do not have the knowhow to fix anything myself.=20

I believe this is where you are totally wrong.  You obviuously have the
ability to create a few simple test cases for yourself and see if the
driver behaves as you expect.  That is very useful.

And you have a device.  That is also useful.

Now, the driver source code is available.  And there is another Asix
driver in the kernel which already has been cleaned up and can be used
as an example. And maybe even partly used for the new devices as well,
if the code is duplicated?  I have not looked at this in detail, but I
suspect that much of the problem with the ax88179_178a driver is that i=
t
has completely ignored all the work that has gone into the asix driver
after it was mainlined.  I find it unlikely that there is no reusable
code in the asix_devices.c, asix_common.c and ax88172a.c files.  Trying
to rewrite ax88179_178a to share as much code as possible seems like th=
e
best way to clean it up and fix bugs.

You have documents like
http://www.kernel.org/doc/Documentation/SubmittingPatches helping a lot
with cleanup jobs like this, because it is mostly about just following
that recipe.  If you do, then the code will be reviewable by the
community because the size will be reduced and the style readable.  And
the driver might even work, as the cleanup will quite possibly reveal a
number of bugs...

Please consider this option.  Reading and fixing up C code is not very
difficult. Getting this driver into the kernel in a good shape is mostl=
y
just monkey work.  But some monkey has to do it :-)


Bj=C3=B8rn
