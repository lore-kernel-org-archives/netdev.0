From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCH 1/2] [TCP]: Add highest_sack seqno, points to globally
 highest SACK
Date: Thu, 8 Mar 2007 16:58:00 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0703081651220.14483@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0703080658180.27671@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-2099465579-1173365880=:14483"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Baruch Even <baruch@ev-en.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49699 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752057AbXCHO6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 09:58:07 -0500
In-Reply-To: <Pine.LNX.4.64.0703080658180.27671@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-2099465579-1173365880=:14483
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 8 Mar 2007, Ilpo Järvinen wrote:

> It is maintained only in during slowpath of tcp_ack().

I think I'll change this to do the forced synchronization of the 
highest_sack to snd_una in sacktag_write_queue when tp->sacked_out is zero 
during entry, which should be much simpler than the current approach.
...and then use if (!tp->sacked_out) to select between snd_una and 
highest_sack entry in the scoreboard updater...

-- 
 i.
---696243703-2099465579-1173365880=:14483--
