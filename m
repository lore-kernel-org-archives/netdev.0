From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] Driver for Solos PCI ADSL2+ card.
Date: Tue, 23 Dec 2008 09:27:14 -0500
Message-ID: <200812231427.mBNEREd3026407@cmf.nrl.navy.mil>
References: <1230041343.22786.441.camel@macbook.infradead.org>
Reply-To: chas3@users.sourceforge.net
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	Nathan Williams <nathan@traverse.com.au>,
	Guy Ellis <guy@traverse.com.au>, Danny@xrio.com
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:49552 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbYLWO1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2008 09:27:38 -0500
Reply-To: chas3@users.sourceforge.net
In-reply-to: <1230041343.22786.441.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <1230041343.22786.441.camel@macbook.infradead.org>,David Woodhouse w
rites:
>+static int opens;

should make this an atomic type.  there is no locking/serialization in
the vcc open/close unless you implement it yourself.
