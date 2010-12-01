From: David Miller <davem@davemloft.net>
Subject: Re: bridge netpoll support: mismatch between net core and bridge
 headers
Date: Wed, 01 Dec 2010 11:42:01 -0800 (PST)
Message-ID: <20101201.114201.245392768.davem@davemloft.net>
References: <AANLkTimbf+yfJFU29rNWAc-hXBxj92J=dNaShM04GNZ7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: vapier.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40966
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751829Ab0LATlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 14:41:35 -0500
In-Reply-To: <AANLkTimbf+yfJFU29rNWAc-hXBxj92J=dNaShM04GNZ7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier.adi@gmail.com>
Date: Sat, 13 Nov 2010 18:26:27 -0500

> so in my randconfig builds, i'm now seeing frequent failures along the lines of:

Mike, I cooked up a patch to "fix" this but I can't reproduce it
in the current tree.

No matter what I do, I can't get CONFIG_NETPOLL and
CONFIG_NET_POLL_CONTROLLER to have different values.

If I try to force it in my ".config" the subsequent "make oldconfig"
forces them to be equal.
