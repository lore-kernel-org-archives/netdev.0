From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: [GIT]: Networking
Date: Wed, 20 Aug 2008 00:39:08 +0300
Message-ID: <200808200039.08948.denys@visp.net.lb>
References: <alpine.LFD.1.10.0808190952000.3324@nehalem.linux-foundation.org> <20080819.140458.236030589.davem@davemloft.net> <alpine.LFD.1.10.0808191411390.3324@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:40022 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754821AbYHSVkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 17:40:22 -0400
In-Reply-To: <alpine.LFD.1.10.0808191411390.3324@nehalem.linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Oh, I'm sure that enabling TSO speeds things up, but apparently it also
> basically enables a code-path that hasn't been enabled since at least
> 2.6.23, no?
Well i report about performance regression before too, seems related case,
but my report was unclear.

And the bug was terrible for me, it was causing very bad performance on 
REDIRECT and loopback transfers. I am testing also recent net-2.6 with this 
loopback changes, it seems improve things for me much. So it is really 
important bugfix for me too.

There is always chances that some fix will cause regression, i will try to 
test this changes on intensive real-life workloads to make sure all fine.
