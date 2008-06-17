From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [Bugme-new] [Bug 10903] New: ssh connections hang with 2.6.26-rc5
Date: Wed, 18 Jun 2008 02:04:43 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806180152410.32420@wrl-59.cs.helsinki.fi>
References: <bug-10903-10286@http.bugzilla.kernel.org/> <200806151537.11986.didier@raboud.com>
 <Pine.LNX.4.64.0806161542290.16829@wrl-59.cs.helsinki.fi>
 <200806172359.33768.didier@raboud.com>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="Boundary-01=_FPDWIJZ2GQsiFPn"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org, linux-wireless@vger.kernel.org
To: Didier Raboud <didier@raboud.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53584 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761925AbYFQXEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 19:04:45 -0400
In-Reply-To: <200806172359.33768.didier@raboud.com>
Content-ID: <Pine.LNX.4.64.0806180152411.32420@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--Boundary-01=_FPDWIJZ2GQsiFPn
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0806180152412.32420@wrl-59.cs.helsinki.fi>
Content-Disposition: inline

On Tue, 17 Jun 2008, Didier Raboud wrote:

> Le lundi 16 juin 2008 15:21:25 Ilpo Järvinen, vous avez écrit :
> > > > > > http://bugzilla.kernel.org/show_bug.cgi?id=10903
> > > > > >
> > > > > >            Summary: ssh connections hang with 2.6.26-rc5
> > > > > >            Product: Networking
> > > > > >            Version: 2.5
> > > > > >      KernelVersion: 2.6.26-rc5
> > > > > >           Platform: All
> > > > > >         OS/Version: Linux
> > > > > >               Tree: Mainline
> > > > > >             Status: NEW
> > > > > >           Severity: normal
> > > > > >           Priority: P1
> > > > > >          Component: Other
> > > > > >         AssignedTo: acme@ghostprotocols.net
> > > > > >         ReportedBy: didier@raboud.com
> > > > > >
> > > > > >
> > > > > > Latest working kernel version: 2.6.25-2
> > > > > > Earliest failing kernel version: 2.6.26-rc5
> > > > > > Distribution: Debian (Lenny + Sid)
> > > > > > Hardware Environment: amd64 (Dell Latitude D630)
> > > > > > Software Environment: KDE
> > > > > > Problem Description:
> > > > > >
> > > > > > With kernel version 2.6.26-rc5, the ssh connections to remote
> > > > > > servers randomly
> > > > > > hang (no error message). No amelioration despite the activation of
> > > > > > "ServerAliveInterval" on both sides.
> > > > (...)
> > > 
> > > The common point is my use of "iwl3945" : I have always tried the ssh
> > > connections through WiFi.
> > > 
> > > > So please gather this information (at least for the relevant
> > > > connections):
> > > >
> > > > $ netstat -pn
> > > > $ cat /proc/net/tcp
> 
> I used a script which logged both every 15 seconds on both sides (in "screen" 
> on server side). I then triggered a hang with several "seq 1 100" in the ssh 
> session. The logs are in the attached debug_ssh_hang.tar.gz . The hang 
> appeared between 234327 and 234342 on the client side (so somewhere between 
> 234324, 234339 and 234354 on the server side).
> 
> I hope it'll help.

Thanks, a quick look didn't indicate anything similar to one other report 
from Håkon... I'd probably need a tcpdump.

> > You probably run it under X, no? Please switch beforehand to some other vt
> > (a textual one) then (Ctrl-Alt-Fn, where n < 6) and then log in and
> > running that command there and see if you get some output into screen
> > there. If you see something (e.g., a sudden OOPS message or some other
> > warning printed) when it locks up, the easiest things is to take a shot
> > with a digicam (or write it down somewhere else) and send that shot (or
> > those details) to us please.
> 
> I tried the following in vt1 (under the new 2.6.26-rc6 with kdm stopped):
> 
> # tcpdump -i wlan0 -w /tmp/tcpdump.wlan0
> 
> and I got the attached "soft lockup".

Thanks, I guess the folks at linux-wireless can continue in resolving this 
one with you (I'm out of time anyway now).

> > ...Once you have a tcpdump, I can probably figure at least something out
> > (though it might still just point to the right direction rather than
> > exposing the actual cause).
> 
> I can't get one... :)

...Ok.

-- 
 i.
--Boundary-01=_FPDWIJZ2GQsiFPn--
