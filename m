From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [Linux-ATM-General] [PATCH] firmware: convert Ambassador ATM
	driver to request_firmware()
Date: Mon, 30 Jun 2008 14:21:12 +0100
Message-ID: <1214832072.10393.342.camel@pmac.infradead.org>
References: <200806301315.m5UDFc0E022495@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:48191 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932132AbYF3NVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 09:21:16 -0400
In-Reply-To: <200806301315.m5UDFc0E022495@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-06-30 at 09:15 -0400, Chas Williams (CONTRACTOR) wrote:
> In message <1214831362.10393.340.camel@pmac.infradead.org>,David Woodhouse writ
> es:
> >And wasn't it sba200e_ecd.bin ? 
> 
> oops.  sparc is big endian.  adding the const we have...

You probably still want the ifdefs for MODULE_FIRMWARE().

-- 
dwmw2

