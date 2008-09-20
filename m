From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-next 04/15] tcp: convert retransmit_cnt_hint to seqno
Date: Sat, 20 Sep 2008 20:59:29 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0809202055270.6906@wrl-59.cs.helsinki.fi>
References: <1221933153-11874-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-5-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-2075510278-1221933569=:6906"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:40089 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbYITR7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 13:59:31 -0400
In-Reply-To: <1221933153-11874-5-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-2075510278-1221933569=:6906
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Sat, 20 Sep 2008, Ilpo Järvinen wrote:

> +
> +	if (!tp->lost_out ||

Never-mind about this patchset, this is a broken to begin with in certain 
cases where we weren't that lucky (once a again the right after posting I 
notice a problem :-)). The problem is basically that we do increments for 
lost_out in many place before calling the verify. I'll fix it and repost 
once I get that done.


-- 
 i.
---696208474-2075510278-1221933569=:6906--
