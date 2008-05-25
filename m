From: David Miller <davem@davemloft.net>
Subject: Re: Single packet receiving in multiple ring buffers
Date: Sun, 25 May 2008 06:04:34 -0700 (PDT)
Message-ID: <20080525.060434.193707056.davem@davemloft.net>
References: <20080523120041.GA16850@2ka.mipt.ru>
	<31256957387BB54C8B9AFE88AA5C0564044A1951@SDCEXCHANGE01.ad.amcc.com>
	<20080525130023.GA27792@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kchudgar@amcc.com, kchudgar.linux@gmail.com, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54332
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755018AbYEYNEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 May 2008 09:04:38 -0400
In-Reply-To: <20080525130023.GA27792@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Sun, 25 May 2008 17:00:24 +0400

> If it is not convenient to use such scheme, you can always put data
> into pages and then copy tiny bit into skb->data to be able to
> specify IP layer protocol, all the rest system will do for itself
> via pskb_may_copy() if needed.

The network input uses "pskb_may_pull()" not "pskb_may_copy()" :-)
