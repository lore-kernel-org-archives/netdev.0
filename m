From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Linux 2.6.25-rc6: WARNING: at net/ipv4/tcp_input.c:2510
Date: Fri, 4 Apr 2008 22:15:43 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804042209530.415@wrl-59.cs.helsinki.fi>
References: <47EBCB75.6030600@unixsol.org> <Pine.LNX.4.64.0804031315360.21524@wrl-59.cs.helsinki.fi>
 <47F5C7D1.1080906@unixsol.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1742740919-1207336543=:415"
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Georgi Chorbadzhiyski <gf@unixsol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42911 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752389AbYDDTSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 15:18:25 -0400
In-Reply-To: <47F5C7D1.1080906@unixsol.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1742740919-1207336543=:415
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 4 Apr 2008, Georgi Chorbadzhiyski wrote:

> Around 04/03/08 13:17, Ilpo Järvinen scribbled:
> > On Thu, 27 Mar 2008, Georgi Chorbadzhiyski wrote:
> > 
> >> A week ago I updated one of my servers to 2.6.25-rc6 and today looking
> >> through logs I've found these:
> >>
> >> [380219.823434] ------------[ cut here ]------------
> >> [380219.823450] WARNING: at net/ipv4/tcp_input.c:2510 tcp_ack+0xc7e/0x177d()
> > 
> > Is this reproducable for you? If yes, is it possible for you to run 
> 
> Not in the moment.
>
> I'm not getting such errors in the log since my last report. Today I'll 
> update to latest -git and will restart the server.

Yeah, the reason why these still happen is that they are quite hard to 
hit.

> The machine that gave me this error is a http and ftp server handling not
> very busy distro mirror (if this can give you any clues).
>
> > processing expensive verification of TCP state (validates TCP write queue 
> > invariants multiple times per ACK by scanning through the write queue) on 
> > such machine?
> 
> How to run such a thing, can you give me some pointers?

I sent the patch recently to netdev/lkml:

  http://marc.info/?l=linux-netdev&m=120733529216457&w=2

But it's very expensive in processing wise so it might not be wise to put 
it in if performance is important for you.


-- 
 i.
---696208474-1742740919-1207336543=:415--
