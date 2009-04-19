From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP: Peer messages
Date: Sun, 19 Apr 2009 14:19:36 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0904191408090.21005@wrl-59.cs.helsinki.fi>
References: <20090418180303.18963ff0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:40766 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756164AbZDSLTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Apr 2009 07:19:39 -0400
In-Reply-To: <20090418180303.18963ff0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 18 Apr 2009, Stephen Hemminger wrote:

> Running some log-term tests of (using bittorrent of latest Ubuntu releases).
> I see no problems with firewall rules (or sky2 driver), but I do several 
> of these: 
> 
> 
> [28286.893945] TCP: Peer <ip scrubbed>:63659/51413 unexpectedly shrunk window 414881290:414894358 (repaired)
> [47312.851937] TCP: Peer <ip scrubbed>:43793/51413 unexpectedly shrunk window 888816585:888823785 (repaired)

This is what was earlier the Treason uncloacked message until somebody 
was scared to death because of it and we had to change the wording.

And it's what the old kernels do for us (and there are plenty of such 
kernels around), and possibly broken middleboxes too. Unless you have a 
tcpdump of a specific case or can clearly say that its frequency is much 
larger than it used to be in some between kernel versions consistent test 
setup, I'm not going to waste my time on debugging obsolete remote ends.

But, now that I think it a bit more, we could possibly but a WARN_ON 
somewhere if we ever sent past advertized window to make a distinction 
between our and their bugs.

-- 
 i.
