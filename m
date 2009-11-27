From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP sockets stalling - help! (long)
Date: Fri, 27 Nov 2009 11:10:51 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911271103590.2459@melkinpaasi.cs.helsinki.fi>
References: <4B0CB1B8.8030402@shiftmail.org> <20091126233302.42be8780@houba>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696230645-749890138-1259312965=:2459"
Cc: Asdo <asdo@shiftmail.org>, Netdev <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net
To: Frederic Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35519 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbZK0JKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 04:10:45 -0500
In-Reply-To: <20091126233302.42be8780@houba>
Content-ID: <alpine.DEB.2.00.0911271109400.2459@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-749890138-1259312965=:2459
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.0911271109401.2459@melkinpaasi.cs.helsinki.fi>

On Thu, 26 Nov 2009, Frederic Leroy wrote:

> Le Wed, 25 Nov 2009 05:25:28 +0100,
> Asdo <asdo@shiftmail.org> a écrit :
> 
> > Hi netdev and e1000 people,
> > 
> > I have a weird problem here.
> > [...]
> 
> I have the same kind of problem at home. I can't copy big files over
> ssh unless I limit the rate ( ssh -l 8000 ... )
> After reading your mail, I make some quick tests ( see below).
> 
> Results in short :
> - netcat always work.
> - ssh stalls, nearly immediately.

One important result is missing though... could you perhaps get a tcpdump 
from the stall and get also the info available in /proc/net/tcp for the 
connection (during the stall), that would help some in figuring out what 
is going on... ...Preferably in new/renamed thread, don't forget to cc me.

-- 
 i.
---696230645-749890138-1259312965=:2459--
