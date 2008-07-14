From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: bnx2_poll panicking kernel
Date: Mon, 14 Jul 2008 19:25:56 +0200
Message-ID: <20080714172556.GB2638@ami.dom.local>
References: <20080710223141.GA2519@orion.carnet.hr> <20080710.162007.04790623.davem@davemloft.net> <20080711092416.GA26515@orion.carnet.hr> <20080711.025656.261409874.davem@davemloft.net> <48787E1A.3030804@gmail.com> <4878AFD8.1000307@gmail.com> <487B7061.5040306@trash.net> <20080714172055.GA2638@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, joy@entuzijast.net,
	mchan@broadcom.com, billfink@mindspring.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	mirrors@debian.org, devik@cdi.cz
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:23386 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754635AbYGNR0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 13:26:25 -0400
Received: by fg-out-1718.google.com with SMTP id 19so2132183fgg.17
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2008 10:26:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080714172055.GA2638@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 14, 2008 at 07:20:55PM +0200, Jarek Poplawski wrote:
...
> IMHO, since this TC_ACT_ issue looks quite rare, David's patch, with
> "htb_activate()" moved to the last "if (ret == NET_XMIT_SUCCESS)"
> blocks, looks like necessary.

...OOOPS! Sorry, IMHO, these htb_activate() simply need their own
"if (ret == NET_XMIT_SUCCESS)" right where they are.

Jarek P.
