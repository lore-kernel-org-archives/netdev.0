From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] [TCP] FRTO: remove unnecessary fackets/sacked_out
 recounting
Date: Mon, 7 May 2007 10:34:33 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0705071028400.3607@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0704211632580.30204@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1842976135-1178522943=:3607"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55425 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754090AbXEGHef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2007 03:34:35 -0400
In-Reply-To: <Pine.LNX.4.64.0704211632580.30204@kivilampi-30.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0705071034290.3607@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1842976135-1178522943=:3607
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0705071029161.3607@kivilampi-30.cs.helsinki.fi>

On Sat, 21 Apr 2007, Ilpo Järvinen wrote:

> F-RTO does not touch SACKED_ACKED bits at all, so there is no
> need to recount them in tcp_enter_frto_loss. After removal of
> the else branch, the nested ifs can be combined.

Just in case you come across this, please do not apply it! I noticed that 
even though it seems very innocent change, it will cause S+L when SACK is 
not in use because sacked_out is not reset. I'll provide updated patch for 
this later on...

-- 
 i.

---696243703-1842976135-1178522943=:3607--
