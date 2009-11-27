From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP sockets stalling - help! (long)
Date: Fri, 27 Nov 2009 23:00:17 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911272256050.11977@melkinpaasi.cs.helsinki.fi>
References: <4B0CB1B8.8030402@shiftmail.org> <20091126233302.42be8780@houba> <4B0FCC6D.3050003@shiftmail.org> <20091127215324.5f494a86@houba>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696230645-83138763-1259355619=:11977"
Cc: Asdo <asdo@shiftmail.org>, Netdev <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net
To: Frederic Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37016 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751841AbZK0VAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 16:00:14 -0500
In-Reply-To: <20091127215324.5f494a86@houba>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-83138763-1259355619=:11977
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Fri, 27 Nov 2009, Frederic Leroy wrote:

> Le Fri, 27 Nov 2009 13:56:13 +0100,
> Asdo <asdo@shiftmail.org> a écrit :
> 
> > Frederic Leroy wrote:
> > > Le Wed, 25 Nov 2009 05:25:28 +0100,
> > > Asdo <asdo@shiftmail.org> a écrit :
> > >
> > >   
> > >> Hi netdev and e1000 people,
> > >>
> > >> I have a weird problem here.
> > >> [...]
> > > I have the same kind of problem at home. I can't copy big files over
> > > [...]
> > Good God it's true then!
> 
> Yes :)
> 
> > Still if I am right, with Netcat you might end up with a corrupted
> > file on the other side (shorter). Or maybe not, depending on how
> > exactly the bug is made. Could you check this? Filesize and md5sum.
> 
> md5sum are ok.
> I can't reproduce the problem on wire with a switch ( using both
> 10 and 100Mbp FD )   
> 
> > Do you have Intel network card, with e1000e driver on SG? (see lsmod) 
> > (sorry I was wrong before, it's e1000e in my case not e1000)
> > Otherwise it's probably the TCP layer...
> 
> Sorry, I forgot to precise the network hardware.
> I forgot a noname 100Mbp switch between the isv box and sg host.
> 
> SG:
> 
> 00:0a.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
> RTL-8139/8139C/8139C+ (rev 10)
> using module 8139cp
> 
> Devel:
> 
> 02:02.0 Network controller: Broadcom Corporation BCM4306 802.11b/g
> Wireless LAN Controller (rev 03)
> using b43 driver.
> 
> 02:08.0 Ethernet controller: Intel Corporation 82801DB PRO/100 VE (MOB)
> Ethernet Controller (rev 81)
> using e100 in kernel ( no module )
> 
> My isv box is broadcom based, but I don't know which chipset for
> wireless.
> 
> Since our hardware are different, I don't think it's coming from
> hardware driver. I'm preparing traces for Ilpo

One worth of checking would be ssh versions if they match (if they have 
broken something, though it's unlikely). I'm also relatively convinced 
that hw issues are not what'll find.

-- 
 i.
---696230645-83138763-1259355619=:11977--
