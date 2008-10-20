From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: tcp_sack problem Re: [Bug 11721] after upgrade to 2.6.27 i cannot
 navigate
Date: Tue, 21 Oct 2008 00:51:26 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810210036040.30254@wrl-59.cs.helsinki.fi>
References: <bug-11721-11547@http.bugzilla.kernel.org/>
 <20081020154737.2D0CA108042@picon.linux-foundation.org>
 <20081020171530.GA2564@ami.dom.local> <20081020214818.09d88b48@topolino>
 <Pine.LNX.4.64.0810202323330.30254@wrl-59.cs.helsinki.fi>
 <20081020233419.78cd4390@topolino>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1195481477-1224538570=:30254"
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: Aldo Maggi <sentiniate@tiscali.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55585 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003AbYJTVv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 17:51:27 -0400
In-Reply-To: <20081020233419.78cd4390@topolino>
Content-ID: <Pine.LNX.4.64.0810210049190.30254@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1195481477-1224538570=:30254
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0810210036191.30254@wrl-59.cs.helsinki.fi>

Reply to all please... ...I restored them again for you... :-)

On Mon, 20 Oct 2008, Aldo Maggi wrote:

> Il giorno Mon, 20 Oct 2008 23:55:48 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> ha scritto:
> 
> [...]
> 
> > Could you try if tcp_window_scaling=1, tcp_sack=1, tcp_timestamps=0
> > also works, if you didn't already (it's not that obvious from the
> > earlier acknowledgement you gave that these were the exact options
> > you used or not)...
> 
> sorry! i was not precise!
> those are exactly the options i tried in my acknowledgment no. 40,
> i.e. tcp_window_scaling and tcp_sack equal to "1" and tcp_timestamps=0

Np, thanks for the confirmation. I sort of assumed this already since 
the alternative interpretation of Jarek's mails didn't make too much 
sense after all (and I jumped into this thread in between, so I just 
scanned them through with haste on the first time concentrating more
on your responses and which of the logs I should download :-)).

> > > moreover, i read more carefully what you and Jarek wrote above,
> > > please let me know if you deem still necessary that i apply the
> > > patch you provided and compile or if you like i compile the latest
> > > kernel or whatever.
> > 
> > If that ws=1,s=1,ts=0 test succeeds, then testing my patch would be
> > useful too. 
> 
> i'm right now compiling the -27-rc1 kernel, on my pc it will take at
> least 3 hrs (that is, it will finish 02.00 rome time :-D )

Ok, I'll check that tomorrow then as mine trimmed down 2.6.28-rc (ah, 
it's still -g something, no rc1 just yet) did complete already :-), just 
going to try to bombard google.it from here too and then it's the bedtime 
for me...

> should it work i'll apply your patch t0 2.6.27.2 and compile again. 

Ok, it's quite likely that both will work with the patch. Anyway, it's 
enough that you do the future tests with 2.6.27.y if we decide to try some 
other ordering (I'll try to think a bit of that tomorrow to see what 
would be to most sensible ordering).

-- 
 i.
---696208474-1195481477-1224538570=:30254--
