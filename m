From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: WARNING: at net/ipv4/tcp_input.c
Date: Mon, 28 Apr 2008 22:21:57 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804282210390.16635@wrl-59.cs.helsinki.fi>
References: <4815BCDF.6070704@andyfurniss.entadsl.com>
 <Pine.LNX.4.64.0804281714090.1888@wrl-59.cs.helsinki.fi>
 <48162070.4030405@andyfurniss.entadsl.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1274454625-1209410112=:16635"
Cc: Netdev <netdev@vger.kernel.org>
To: Andy Furniss <lists@andyfurniss.entadsl.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44094 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934597AbYD1TWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 15:22:00 -0400
In-Reply-To: <48162070.4030405@andyfurniss.entadsl.com>
Content-ID: <Pine.LNX.4.64.0804282215220.16635@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1274454625-1209410112=:16635
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0804282215221.16635@wrl-59.cs.helsinki.fi>

On Mon, 28 Apr 2008, Andy Furniss wrote:

> Ilpo Järvinen wrote:
> > On Mon, 28 Apr 2008, Andy Furniss wrote:
> > 
> > > Since upgrading to 2.6.25 from 2.6.21.1 I've noticed a few of these.
> > 
> > ...Thanks for the report, you could actually reproduce it in non-infinite
> > time?? ...Finally somebody who might actually have a change to catch this
> > shows up... :-)
> 
> Hopefully - grepping shows I've had a few,

More than one is a good start already. Most people who have reported had 
just one or have a loaded server which isn't that suitable for expensive
tracking that is necessary.

> I was running -rc7 for a while and
> see a different message from that. I changed to .25 on the 21st.

Anything pre -rc9 is not worth to mention. There have been other issues 
that were fixed in it.

> > I've tried to catch these with torrent but never got anything, it seems to
> > be quite sensitive to "network weather", which varies too much for me to
> > catch it. Maybe I'll try w/o timestamps if that helps me to reproduce it
> > (more likely).
> 
> Could be my qos shaking things up. bt uses piggy backed acks and I must drop a
> fair few. I probably reorder a bit as well by treating small tcp as higher
> prio than large. Egress tcp is also mss clamped to 1150.

Thanks for the info, though I've tried to use netem to generate some 
reordering & drops in my setup but just couldn't make it to happen with 
them either.

> > The debug patch below will add considerable amount of processing per ACK to
> > verify where this invariant gets broken for the first time, in case that's
> > fine with your server, please consider adding that and waiting until it
> > spits something out... :-)
> 
> No problem it's 90% idle most of the time and my wan isn't that fast.
>
> I'll rebuild tonight.

Thanks.

-- 
 i.
---696208474-1274454625-1209410112=:16635--
