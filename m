From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: net-next: mii-tool qweasd: Unable to handle kernel NULL ptr
	dereference
Date: Mon, 22 Dec 2008 06:41:46 +0000
Message-ID: <20081222064146.GA2631@ff.dom.local>
References: <m3y6y9qb2w.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:65067 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244AbYLVGlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 01:41:51 -0500
Received: by nf-out-0910.google.com with SMTP id d3so259334nfc.21
        for <netdev@vger.kernel.org>; Sun, 21 Dec 2008 22:41:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <m3y6y9qb2w.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22-12-2008 01:59, Krzysztof Halasa wrote:
> Hmm...
> 
> IXP4xx (ARM), basically net-next:
> 
> # mii-tool qweasd
> 
> Unable to handle kernel NULL pointer dereference at virtual address 000000b4
> pgd = c66b4000
> [000000b4] *pgd=066eb031, *pte=00000000, *ppte=00000000
> Internal error: Oops: 17 [#1]
> Modules linked in: ixp4xx_hss ixp4xx_eth ixp4xx_npe ixp4xx_qmgr e1000
> CPU: 0    Not tainted  (2.6.28-rc8 #81)
> PC is at dev_ifsioc+0x24/0x3f8
...
> I can bisect this but perhaps someone already knows what's wrong?

Looks similarly to this problem:

http://marc.info/?l=linux-netdev&m=122967029022058&w=2

Jarek P.
