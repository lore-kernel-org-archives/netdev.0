From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 0/4] Fix forcedeth hibernate/wake-on-lan problems
Date: Wed, 4 Jun 2008 19:38:01 -0700
Message-ID: <200806041938.02045.david-b@pacbell.net>
References: <20080518125715.GA19229@yamamaya.is-a-geek.org> <200805271432.12881.david-b@pacbell.net> <20080531072036.GC5405@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tobias Diedrich <ranma+kernel@tdiedrich.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-acpi@vger.kernel.org, linux-pm@lists.linux-foundation.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763592AbYFECis@vger.kernel.org>
In-Reply-To: <20080531072036.GC5405@ucw.cz>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 31 May 2008, Pavel Machek wrote:
>=20
> > Yeah; under ACPI, PCI does not act like it does everywhere else.
> > Nor does wakeup in general.
> >=20
> > After sending patches to fix that for a couple years now, I'm
> > well past being tired of doing that. =A0I suggest it's overdue for
> > the ACPI team to get this part of their act together.
>=20
> I'm afraid you expect too much from the acpi team.

I'm likewise "afraid" that may be too much to expect.

If that's true, it's going to be even harder making
the cross-platform Linux PM framework do what it needs
to do.  Having various devices (not just laptop lids or
power buttons, or RTC alarms) wake systems from low power
states is pretty fundamental to the "P" part of ACPI.
And it's not like wakeup events are unique to ACPI.


> If you can't merge=20
> patches yourself, perhaps someone interested (Tobias? me?) can push
> them for you?

I kind of think the ACPI team needs to just become more
responsive.  They helped Windows do this stuff; why has
Linux only seen delays and obstacles in this area?
