From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.24-rc8-mm1 : net tcp_input.c warnings
Date: Wed, 23 Jan 2008 13:01:39 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801231256360.31652@kivilampi-30.cs.helsinki.fi>
References: <a8e1da0801220109v6bf8931ev50f2210402c3ba41@mail.gmail.com>
 <Pine.LNX.4.64.0801221115150.31652@kivilampi-30.cs.helsinki.fi>
 <a8e1da0801221744m37021e88h5c188e5b31ea42bf@mail.gmail.com>
 <20080122.190137.206066966.davem@davemloft.net>
 <Pine.LNX.4.64.0801230937270.31652@kivilampi-30.cs.helsinki.fi>
 <a8e1da0801222344l101c2b90s363821c26bc8cb55@mail.gmail.com>
 <Pine.LNX.4.64.0801231034300.31652@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-2498209-1201077674=:31652"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Dave Young <hidave.darkstar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52817 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbYAWLB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 06:01:58 -0500
In-Reply-To: <Pine.LNX.4.64.0801231034300.31652@kivilampi-30.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0801231300530.31652@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-2498209-1201077674=:31652
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0801231256362.31652@kivilampi-30.cs.helsinki.fi>

On Wed, 23 Jan 2008, Ilpo Järvinen wrote:

> On Wed, 23 Jan 2008, Dave Young wrote:
> 
> > On Jan 23, 2008 3:41 PM, Ilpo Järvinen <ilpo.jarvinen@helsinki.fi> wrote:
> > >
> > > On Tue, 22 Jan 2008, David Miller wrote:
> > >
> > > > From: "Dave Young" <hidave.darkstar@gmail.com>
> > > > Date: Wed, 23 Jan 2008 09:44:30 +0800
> > > >
> > > > > On Jan 22, 2008 6:47 PM, Ilpo Järvinen <ilpo.jarvinen@helsinki.fi> wrote:
> > > > > > [PATCH] [TCP]: debug S+L
> > > > >
> > > > > Thanks, If there's new findings I will let you know.
> > > >
> > > > Thanks for helping with this bug Dave.
> > >
> > > I noticed btw that there thing might (is likely to) spuriously trigger at
> > > WARN_ON(sacked != tp->sacked_out); because those won't be equal when SACK
> > > is not enabled. If that does happen too often, I send a fixed patch for
> > > it, yet, the fact that I print print tp->rx_opt.sack_ok allows
> > > identification of those cases already as it's zero when SACK is not
> > > enabled.
> > >
> > > Just ask if you need the updated debug patch.
> > 
> > Thanks,  please send, I would like to get it.
> 
> There you go. I fixed non-SACK case by adding tcp_is_sack checks there and 
> also added two verifys to tcp_ack to see if there's corruption outside of 
> TCP.

There's some discussion about a problem that is very likely the same as in 
here (sorry for not remembering to cc you in there due to rapid progress):

   http://marc.info/?t=120107174200003&r=1&w=2


-- 
 i.
---696243703-2498209-1201077674=:31652--
