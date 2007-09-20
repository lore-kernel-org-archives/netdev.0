From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 9/9] [TCP]: Avoid clearing sacktag hint in trivial
 situations
Date: Thu, 20 Sep 2007 22:18:13 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0709202214460.7764@kivilampi-30.cs.helsinki.fi>
References: <1190290672980-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11902906723907-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11902906723220-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20070920.114106.124084391.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-563381914-1190315893=:7764"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36331 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbXITTSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 15:18:16 -0400
In-Reply-To: <20070920.114106.124084391.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-563381914-1190315893=:7764
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 20 Sep 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Thu, 20 Sep 2007 15:17:52 +0300
> 
> > There's no reason to clear the sacktag skb hint when small part
> > of the rexmit queue changes. Account changes (if any) instead when
> > fragmenting/collapsing. RTO/FRTO do not touch SACKED_ACKED bits so
> > no need to discard SACK tag hint at all.
> > 
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> 
> Applied, and I followed it up with this coding style fixlet.

Yeah, that's for fixing it... ...Just didn't notice it was left wrong 
while doing things that required more thinking to get them right...

-- 
 i.

---696243703-563381914-1190315893=:7764--
