From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH]: tcp: Fix queue traversal in tcp_use_frto().
Date: Wed, 24 Sep 2008 13:08:04 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0809241248560.1034@wrl-59.cs.helsinki.fi>
References: <20080923.025542.193703353.davem@davemloft.net>
 <Pine.LNX.4.64.0809232214320.14360@wrl-59.cs.helsinki.fi>
 <20080923.150034.74273991.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-2113557826-1222250884=:1034"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56088 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751359AbYIXKII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 06:08:08 -0400
In-Reply-To: <20080923.150034.74273991.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-2113557826-1222250884=:1034
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 23 Sep 2008, David Miller wrote:

> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Tue, 23 Sep 2008 22:18:33 +0300 (EEST)
> 
> > For the record (as you probably know it already), this wasn't actually
> > a real bug though it hits your BUG_ON since tcp_for_write_queue_from exits
> > immediately, no garbage gets dereferenced.
> 
> Yes, that is correct.
>
> It is actually disappointing for me, I thought maybe it would catch
> a real bug somewhere :-)

Rest assured, it will definately do that once some rewrite or so 
happens... :-)

-- 
 i.
---696208474-2113557826-1222250884=:1034--
