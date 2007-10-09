From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCH net-2.6.24 0/3]: Attempt to fix lost_retrans brokeness
Date: Tue, 9 Oct 2007 16:03:29 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710091600300.3767@kivilampi-30.cs.helsinki.fi>
References: <11919324023597-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1001774710-1191935009=:3767"
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	TAKANO Ryousei <takano@axe-inc.co.jp>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33369 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753412AbXJINDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 09:03:33 -0400
In-Reply-To: <11919324023597-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1001774710-1191935009=:3767
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 9 Oct 2007, Ilpo Järvinen wrote:

> Lost_retrans handling of sacktag was found to be flawed, two
> problems that were found have an intertwined solution. Fastpath
> problem has existed since hints got added and the other problem
> has probably been there even longer than that. ...This change
> may add non-trivial processing cost.
> 
> Initial sketch, only compile tested. This will become more and
> more useful, when sacktag starts to process less and less skbs,
> which hopefully happens quite soon... :-) Sadly enough it will
> probably then be consuming part of the benefits we're able to
> achieve by less skb walking...
> 
> First one is trivial, so Dave might want to apply it already.

Hmm, forgot to add -n to git-format-patch. Since it's currently
RFC, I won't bother to resubmit with numbers unless somebody
really wants that. Here's the correct ordering, if it's not
obvious from the patches alone:

$ git-log -n 3 --pretty=oneline HEAD | cat
c628f5040cf31323f9166d41cb46070aa7be8cc5 [TCP]: Limit processing lost_retrans loop to work-to-do cases
b7388980b7bfa1b9159a65a81b9501df43c67b08 [TCP]: Fix lost_retrans loop vs fastpath problems
a1c39117034c58bf786a5941dd7e9a5968439007 [TCP]: Separate lost_retrans loop into own function


-- 
 i.
---696243703-1001774710-1191935009=:3767--
