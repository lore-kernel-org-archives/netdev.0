From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-next] tcp: kill pointless urg_mode
Date: Fri, 3 Oct 2008 23:32:49 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810032328550.30507@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0810030050001.23164@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="-696208474-1333229167-1222984546=:23164"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49670 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687AbYJCUdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2008 16:33:24 -0400
In-Reply-To: <Pine.LNX.4.64.0810030050001.23164@wrl-59.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0810032328551.30507@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1333229167-1222984546=:23164
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0810032328552.30507@wrl-59.cs.helsinki.fi>

On Fri, 3 Oct 2008, Ilpo Järvinen wrote:

> It all started from me noticing that this urgent check in
> tcp_clean_rtx_queue is unnecessarily inside the loop. Then
> I took a longer look to it and found out that the users of
> urg_mode can trivially do without. Just drag snd_up with
> us when we advance.

Please hold a minute with this one while I inspect why I saw
some strange urg now in a tcpdump.

--
 i.

---696208474-1333229167-1222984546=:23164--
