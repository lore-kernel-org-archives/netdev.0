From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP IPv4 strange retransmits
Date: Tue, 4 Mar 2008 23:19:38 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0803042309240.15040@kivilampi-30.cs.helsinki.fi>
References: <47CD4808.1050202@nets.rwth-aachen.de>
 <Pine.LNX.4.64.0803041507001.5423@kivilampi-30.cs.helsinki.fi>
 <47CD5D43.9020408@nets.rwth-aachen.de> <Pine.LNX.4.64.0803042243050.15040@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="-696243703-735047333-1204664168=:15040"
Cc: Netdev <netdev@vger.kernel.org>
To: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36834 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756725AbYCDVTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 16:19:42 -0500
In-Reply-To: <Pine.LNX.4.64.0803042243050.15040@kivilampi-30.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0803042309241.15040@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-735047333-1204664168=:15040
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0803042256361.15040@kivilampi-30.cs.helsinki.fi>

On Tue, 4 Mar 2008, Ilpo Järvinen wrote:

> In addition, the ACKs are processed in order and their effects are 
> immediate even if there's more information awaiting to be processed.

Before somebody asks or suggests (one might be tempted to think it's a 
good idea), no, we likely don't want to do it other way around unless 
somebody first proves that it won't negatively affect TCP's ACK clock,
and would benefits only some corner-case like this (and even in such 
case, one might get bitten by the tcp_max_burst). It would of course be 
possible to come up with a solution that reverse those _and_ fixes the 
ACK clock problems caused by such approach. The problems are similar to 
what LRO is causing btw, so it might not be complete waste of efforts to 
fix the ACK clock problems and reuse the solution in LRO as well.


-- 
 i.
---696243703-735047333-1204664168=:15040--
