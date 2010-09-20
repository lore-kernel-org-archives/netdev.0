From: David Miller <davem@davemloft.net>
Subject: Re: E1000E/82567LM-3: link reported up too soon
Date: Mon, 20 Sep 2010 12:54:47 -0700 (PDT)
Message-ID: <20100920.125447.220082714.davem@davemloft.net>
References: <87bp7vnnpj.fsf@small.ssi.corp>
	<20100920.112213.42810338.davem@davemloft.net>
	<878w2wnsyd.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, netdev@vger.kernel.org
To: arno@natisbad.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43165
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751865Ab0ITTy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 15:54:28 -0400
In-Reply-To: <878w2wnsyd.fsf@small.ssi.corp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: arno@natisbad.org (Arnaud Ebalard)
Date: Mon, 20 Sep 2010 20:57:46 +0200

> On some ethernet devices (at least), link may be reported up (NEWLINK
> received by userspace with flags indicating UP and RUNNING) before the
> interface is really usable. When sending packets as soon as the link is
> available, the first one may be dropped. That's what you see on the
> capture above.

The link being up doesn't mean an address has been assigned to the
interface for the protocol you are using yet.

I think you have to schedule whatever it is you need to make sure it
runs after dhcp successfully complete.
