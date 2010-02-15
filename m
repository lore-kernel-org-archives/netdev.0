From: jamal <hadi@cyberus.ca>
Subject: Re: [net-next-2.6 PATCH 1/7] xfrm: introduce basic mark
 infrastructure
Date: Mon, 15 Feb 2010 12:00:35 -0500
Message-ID: <1266253235.6776.90.camel@bigi>
References: <xfrm-mark-net-next>
	 <1266160732-946-1-git-send-email-hadi@cyberus.ca>
	 <1266160732-946-2-git-send-email-hadi@cyberus.ca>
	 <4B796B70.2050102@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, herbert@gondor.apana.org.au,
	davem@davemloft.net, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f224.google.com ([209.85.217.224]:54607 "EHLO
	mail-gx0-f224.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755774Ab0BORAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 12:00:37 -0500
Received: by gxk24 with SMTP id 24so5063401gxk.1
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2010 09:00:36 -0800 (PST)
In-Reply-To: <4B796B70.2050102@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-02-15 at 16:42 +0100, Patrick McHardy wrote:


> This doesn't look right. A mark value of 0 with a mask of ~0 won't
> be properly dumped. I think this should check for (m->m | m->v).
> 

Good point, thanks. I will make that change;

Rest of patches look reasonable?

cheers,
jamal

