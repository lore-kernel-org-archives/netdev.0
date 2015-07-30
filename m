From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: Re: [PATCH] bus: subsys: update return type of ->remove_dev() to void
Date: Thu, 30 Jul 2015 16:31:10 +0530
Message-ID: <20150730110110.GA24546@linux>
References: <02c0569741812b655edde5124c3e2937bb79f9f8.1438248445.git.viresh.kumar@linaro.org>
 <20150730105917.GA25460@nazgul.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rjw@rjwysocki.net>,
	Chris Metcalf <cmetcalf@ezchip.com>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	Joe Perches <joe@perches.com>, Joerg Roedel <jroedel@suse.de>,
	open list <linux-kernel@vger.kernel.org>,
	"open list:CPU FREQUENCY DRIVERS" <linux-pm@vger.kernel.org>,
	"open list:SUPERH" <linux-sh@vger.kernel.org>,
	"Luis R. Rodriguez" <mcgrof@suse.com>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	Nicolas Iooss <nicolas.iooss_linux@m4x.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>
To: Borislav Petkov <bp@alien8.de>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150730105917.GA25460@nazgul.tnic>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30-07-15, 12:59, Borislav Petkov wrote:
> On Thu, Jul 30, 2015 at 03:04:01PM +0530, Viresh Kumar wrote:
> > Its return value is not used by the subsys core and nothing meaning=
ful
> > can be done with it, even if we want to use it. The subsys device i=
s
> > anyway getting removed.
>=20
> I'm assuming sysfs paths covered by it, will remain intact... ? For t=
he
> microcode loader case that's this hierarchy here:
>=20
> $ tree /sys/devices/system/cpu/cpu?/microcode/
> /sys/devices/system/cpu/cpu0/microcode/
> =E2=94=9C=E2=94=80=E2=94=80 processor_flags
> =E2=94=94=E2=94=80=E2=94=80 version
> /sys/devices/system/cpu/cpu1/microcode/
> =E2=94=9C=E2=94=80=E2=94=80 processor_flags
> =E2=94=94=E2=94=80=E2=94=80 version

Yeah, Its not touching the sysfs path at all.

--=20
viresh
