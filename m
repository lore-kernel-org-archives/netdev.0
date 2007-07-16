From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: Re: IPSec freeze
Date: Mon, 16 Jul 2007 18:49:36 +0200
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD13230244@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:51269 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932579AbXGPQtm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 12:49:42 -0400
Received: from exch.facton.local (exch [192.168.200.5])
	by alpha.facton.com (8.13.8/8.13.8/FACTON) with ESMTP id l6GGnau7027548
	for <netdev@vger.kernel.org>; Mon, 16 Jul 2007 18:49:36 +0200
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Today a new site joined our Linux IPSec VPN, now all the 
> other routers (all 2.6.22) freeze hard reproducible.
> No oops, no sysreq, only hard reset rewakes them.

Ok, I did a longer test and nothing crashed in the mean time without
IPComp.
So it really must have been the reason.

BTW now I see the "pmtu discovery on SA" regression in 2.6.22, there is
already another thread about.
With 2.6.15 we had this already, but a patch from Herbert fixed it (TOS
field matching in ICMP IIRC).

Daniel
