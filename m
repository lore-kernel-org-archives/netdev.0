From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.29-rc5-git3 Leak r=1 3
Date: Fri, 20 Feb 2009 18:18:13 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0902201817500.31742@wrl-59.cs.helsinki.fi>
References: <200902192304.35547.denys@visp.net.lb> <200902201349.47984.denys@visp.net.lb>
 <Pine.LNX.4.64.0902201805400.31742@wrl-59.cs.helsinki.fi>
 <200902201812.47205.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1222526265-1235146693=:31742"
Cc: Netdev <netdev@vger.kernel.org>
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50352 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927AbZBTQSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 11:18:15 -0500
In-Reply-To: <200902201812.47205.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1222526265-1235146693=:31742
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 20 Feb 2009, Denys Fedoryschenko wrote:

> On Friday 20 February 2009 18:09:54 Ilpo Järvinen wrote:
> > > [45853.641072] TCP: Peer 172.16.193.87:1259/8080 unexpectedly shrunk
> > > window 1905466446:1905480750 (repaired)
> >
> > Hmm, we might have sent past our allowed window due to some bug. ...Or
> > combined some segments in the new shifting code incorrectly past the
> > right edge of the window though I quickly checked and we do check for
> > tcp_send_head there so it should be right.
> 
> 
> This message (about window), i have tons of them, and had before a lot. 
> 
> I think it is not related, just i paste whole dmesg part where i see 
> more "Leak" messages. I'm sure i have more of them now.

Ah, ok. Thanks for letting me know.

-- 
 i.
---696208474-1222526265-1235146693=:31742--
