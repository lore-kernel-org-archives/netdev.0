From: Mihai =?UTF-8?B?RG9uyJt1?= <mihai.dontu@gmail.com>
Subject: Re: [Bug 40422] New: 3.0: kernel panic - not syncing: fatal
 exception in interrupt
Date: Tue, 2 Aug 2011 00:45:58 +0300
Message-ID: <20110802004558.393e2a77@mdontu-dell>
References: <bug-40422-27@https.bugzilla.kernel.org/>
	<20110801140418.510c5dc4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bugzilla-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64501 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034Ab1HAVt1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 17:49:27 -0400
In-Reply-To: <20110801140418.510c5dc4.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 1 Aug 2011 14:04:18 -0700 Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via
> the bugzilla web interface).
>=20
> On Mon, 1 Aug 2011 20:51:43 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>=20
> > https://bugzilla.kernel.org/show_bug.cgi?id=3D40422
> >=20
> >            Summary: 3.0: kernel panic - not syncing: fatal
> > exception in interrupt
> >            Product: Memory Management
> >            Version: 2.5
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Other
> >         AssignedTo: akpm@linux-foundation.org
> >         ReportedBy: mihai.dontu@gmail.com
> >         Regression: No
> >=20
> >=20
> > Upon resuming from suspend to disk, I got a kernel panic like it
> > can be seen in the attached picture. I'm using 3.0 for less than a
> > week and this is the first time this happens (after several
> > successful suspend+resume-s).
> >=20
>=20
> --- Comment #1 from Mihai Don#u <mihai.dontu@gmail.com>  2011-08-01
> 20:55:23 --- Created an attachment (id=3D67322)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=3D67322)
> kernel panic camera shot
>=20
> drat, the first part of that crash scrolled off the screen or wasn't
> in the photo.  I don't suppose it's possible to get that information?

No, I'm afraid not. I'll disable the framebuffer decorations for the
future. Should get me 4 or 5 more lines of backtrace when the crash
reappears.

> Still, the oops is in netfilter code - a bad pointer dereference unde=
r
> devinet_ioctl->masq_device_event.

--=20
Mihai Don=C8=9Bu
