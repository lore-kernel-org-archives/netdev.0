From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCH] [TCP]: Fix lost_retrans loop vs fastpath problems
Date: Thu, 11 Oct 2007 13:12:49 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710111300280.23026@kivilampi-30.cs.helsinki.fi>
References: <11919324023597-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11919324023846-git-send-email-ilpo.jarvinen@helsinki.fi>
 <119193240269-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20071011.105526.17823985.takano@axe-inc.co.jp>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1266507317-1192097569=:23026"
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: TAKANO Ryousei <takano@axe-inc.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49371 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757745AbXJKKMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 06:12:52 -0400
In-Reply-To: <20071011.105526.17823985.takano@axe-inc.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1266507317-1192097569=:23026
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 11 Oct 2007, TAKANO Ryousei wrote:

> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> Subject: [RFC PATCH] [TCP]: Fix lost_retrans loop vs fastpath problems
> Date: Tue,  9 Oct 2007 15:20:01 +0300
> 
> Thanks Ilpo!  I am trying to evaluate this patch.

There's a minor problem in this 2nd patch, it's just preventing the 
cnt == tp->retrans_out short-circuit from working, not a correctness 
problem though it could affect the performance. I'll post larger patch 
series among which is a fixed version (hopefully today).

> But, I got 
> a kernel panic at net_rx_action() in our experimental setting.
> I am using the net-2.6.24 kernel _without_ this patch. 
> (I will post a bug report separately).

...Please do. :-)

> Anyway, I will report the result as soon as possible.

Thanks. ...It's very interesting to see because it's not that clear
cut how the extra processing that is necessary affects high-speed 
performance, it could add yet another source of RTOs due
processing latency.

-- 
 i.
---696243703-1266507317-1192097569=:23026--
