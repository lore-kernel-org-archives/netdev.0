From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 1/5] tcp: make is_dupack a parameter to
 tcp_fastretrans_alert()
Date: Thu, 17 Nov 2011 03:23:53 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1111170323020.1205@melkinpaasi.cs.helsinki.fi>
References: <1321469885-10885-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1681780376-1321493033=:1205"
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36839 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754751Ab1KQBXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 20:23:55 -0500
In-Reply-To: <1321469885-10885-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1681780376-1321493033=:1205
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

On Wed, 16 Nov 2011, Neal Cardwell wrote:

> Allow callers to decide whether an ACK is a duplicate ACK. This is a
> prerequisite to allowing fastretrans_alert to be called from new
> contexts, such as the no_queue and old_ack code paths, from which we
> have extra info that tells us whether an ACK is a dupack.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

-- 
 i.
--8323329-1681780376-1321493033=:1205--
