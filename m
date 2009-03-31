From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2927 tcp_ack+0xd55/0x1991()
Date: Tue, 31 Mar 2009 12:16:51 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0903311205070.30150@wrl-59.cs.helsinki.fi>
References: <20090327211202.GA10014@gentoox2.trippelsdorf.de>
 <Pine.LNX.4.64.0903280031080.5904@wrl-59.cs.helsinki.fi>
 <20090328045056.GA2394@gentoox2.trippelsdorf.de>
 <Pine.LNX.4.64.0903280930440.6696@wrl-59.cs.helsinki.fi>
 <20090328095514.GA2599@gentoox2.trippelsdorf.de>
 <Pine.LNX.4.64.0903301155150.30150@wrl-59.cs.helsinki.fi>
 <20090330164035.GA2652@gentoox2.trippelsdorf.de>
 <Pine.LNX.4.64.0903302137100.29272@wrl-59.cs.helsinki.fi>
 <20090331071018.GA2641@gentoox2.trippelsdorf.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-2004850153-1238491011=:30150"
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, corbet@lwn.net
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35854 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211AbZCaJQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 05:16:55 -0400
In-Reply-To: <20090331071018.GA2641@gentoox2.trippelsdorf.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-2004850153-1238491011=:30150
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 31 Mar 2009, Markus Trippelsdorf wrote:

> On Mon, Mar 30, 2009 at 09:52:55PM +0300, Ilpo Järvinen wrote:
> > On Mon, 30 Mar 2009, Markus Trippelsdorf wrote:
> > 
> > > On Mon, Mar 30, 2009 at 07:01:22PM +0300, Ilpo Järvinen wrote:
> > > > On Sat, 28 Mar 2009, Markus Trippelsdorf wrote:
> > > > > On Sat, Mar 28, 2009 at 10:29:58AM +0200, Ilpo Järvinen wrote:
> > > > 
> > > > ...And, let me guess, you're in X and therefore unable to catch a final 
> > > > oops if any would be printed? It would be nice to get around that as well, 
> > > > either use serial/netconsole or hang in text mode while waiting for the 
> > > > crash (should be too hard if you are able to setup the workload first 
> > > > and then switch away from X and if reproducing takes about an hour)...
> > > 
> > > OK, I will try this later.
> > 
> > Lets hope that gives some clue where it ends up going boom (if it is 
> > caused by TCP we certainly should see something more sensible in console 
> > than just a hang)... ...I once again read through tcp commits but just 
> > cannot find anything that could cause fackets_out miscount, not to speak 
> > of crash prone changes so we'll just have to wait and see...
> 
> The machine hanged again this night and I took two pictures:
> http://www.mypicx.com/uploadimg/1055813374_03302009_2.jpg
> http://www.mypicx.com/uploadimg/1543678904_03302009_1.jpg
>
> But this time there was no tcp related warning in the logs.

Right. If that oops would be hit often enough one can easily mix the 
warning with that hang though there is no relation (the fact that final 
oops always goes unnoticed in X amplifies the effect).

> I then pulled the lateset git changes, rebuild, rebooted and setup the
> workload again. The machine was still up and running in the morning 
> (~4 hours uptime). So it may well be that the issue was fixed with
> the latest changes.

Lets hope so, in any case if you still see hangs please get the final oops.

> If it ever occurs again I will notify you.

Thanks. Also, if you keep getting those TCP warnings (even alone without
a crash) please drop me a note since I'd be interesting in tracking that 
down as well even though it is probably not very significant flaw. Even 
once a week/month is very promising rate considering how rare they occur 
for most of the people who were lucky enough to get them in the first 
place.


-- 
 i.
---696208474-2004850153-1238491011=:30150--
