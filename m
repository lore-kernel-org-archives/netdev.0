From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
 (fwd)
Date: Wed, 1 Oct 2008 15:52:19 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1265043786-1222865539=:1034"
Cc: Netdev <netdev@vger.kernel.org>
To: "=?ISO-8859-1?Q?D=E2niel_Fraga?=" <fragabr@gmail.com>,
	tglx@linutronix.de, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58657 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753101AbYJAMxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 08:53:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1265043786-1222865539=:1034
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

Hi Daniel,

I forward part of the details to public knowledge (and for Thomas mainly).

I also put the epoll & accept only log available for him at
http://www.cs.helsinki.fi/u/ijjarvin/tcp/epoll_accept.txt
as it won't contain encryption key, etc. related bits.

Can you Daniel please confirm what exactly was the status about the effect 
of disabling ntpd?

-- 
 i.

---------- Forwarded message ----------
From: Dâniel Fraga <fragabr@gmail.com>
To: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Tue, 23 Sep 2008 00:56:17 -0300

On Mon, 22 Sep 2008 14:22:12 +0300 (EEST)
"Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> When using nmap to resolve, take note on exact timestamp (including 
> seconds). E.g., 
> $ date > nmap.ts; nmap ...

	Hi Ilpo, so we can hurry up this debug, I'm sending before,
during and after the stall, just to you:

	Obs.: the stall happened at +- 13:06:47... you'll notice lots of epoll_wait.

	The nmap was done at +- 13:07:15.

	Thanks again! :)

---696208474-1265043786-1222865539=:1034--
