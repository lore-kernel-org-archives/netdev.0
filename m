From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH] Driver-core: Fix bluetooth network device rename
	regression
Date: Tue, 27 Jul 2010 20:24:31 +0200
Message-ID: <AANLkTi=ttTjec7RjUZRM9v5WtLEYNPtH9L2qx8Js1WCT@mail.gmail.com>
References: <AANLkTimM5Ea8mQ7aX4kDq3dgF3P-t2Wm3dERhckC69Ja@mail.gmail.com>
	<m1vd87toy9.fsf@fess.ebiederm.org> <AANLkTil3Q1Vobw48AvStl9gphaJcyUGlt6ZnMLanDMVn@mail.gmail.com>
	<1279822828.12439.24.camel@jlt3.sipsolutions.net> <20100722182827.GA12821@suse.de>
	<1279823801.12439.31.camel@jlt3.sipsolutions.net> <20100722185449.GB528@suse.de>
	<m1eievugon.fsf@fess.ebiederm.org> <20100726180941.GB4883@kroah.com>
	<AANLkTincg-0-h1aqW4A=z6A+HTbOfkCCWKDD18ZUEGSn@mail.gmail.com>
	<20100727134904.GA4994@kroah.com> <m14ofkiybo.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <greg@kroah.com>, Greg KH <gregkh@suse.de>,
	Johannes Berg <johannes@sipsolutions.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:46317 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753271Ab0G0SYs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 14:24:48 -0400
Received: by qyk7 with SMTP id 7so2861460qyk.19
        for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 11:24:47 -0700 (PDT)
In-Reply-To: <m14ofkiybo.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 27, 2010 at 20:17, Eric W. Biederman <ebiederm@xmission.com=
> wrote:
> Greg KH <greg@kroah.com> writes:

> Let me say this again clearly.
>
> class -> bus BROKEN
>
> In the case of bluetooth it would require changing /sys/class/bluetoo=
th
> to /sys/bus/bluetooth. =C2=A0Which is user visible in the worst possi=
ble
> way and quick google search confirmed it will break user space script=
s.

Clearly, we even have a compat API for that, and nothing would break.
If needed, a bus can create compat class links. Did you even check
with the bluetooth guys, last time I talked to them, they have been
totally fine with such a change.

Kay
