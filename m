From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-2.6.22 1/3] [TCP]: Sed magic converts func(sk, tp,
 ...) -> func(sk, ...)
Date: Mon, 16 Apr 2007 18:52:10 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0704161841270.28337@kivilampi-30.cs.helsinki.fi>
References: <1176727728729-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20070416134818.GA15915@infradead.org> <Pine.LNX.4.64.0704161703170.28337@kivilampi-30.cs.helsinki.fi>
 <46238B13.5070201@trash.net> <Pine.LNX.4.64.0704161758020.28337@kivilampi-30.cs.helsinki.fi>
 <462396F5.9030907@trash.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-2058577040-1176738730=:28337"
Cc: Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54345 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030761AbXDPPwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 11:52:11 -0400
In-Reply-To: <462396F5.9030907@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-2058577040-1176738730=:28337
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 16 Apr 2007, Patrick McHardy wrote:

> Ilpo Järvinen wrote:
> > On Mon, 16 Apr 2007, Patrick McHardy wrote:
> > 
> > [...] It's not clear to me what is really the preferred 
> > style considering all the variants... [...]
> 
> The preferred style is a newline after variable declarations. Some
> (mostly old) code doesn't consistently do that, but in cases where
> you add the first local variable you should really add them.

Just to make sure... And this holds in all cases, e.g., in 2 lines 
functions too like tcp_push_pending_frames? Maybe I'm just being too
picky or something... :-)


-- 
 i.
---696243703-2058577040-1176738730=:28337--
