From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] gigaset: in file ops, check for device disconnect
 before anything else
Date: Mon, 06 Apr 2009 17:43:40 -0700 (PDT)
Message-ID: <20090406.174340.253577345.davem@davemloft.net>
References: <20090404-patch-00.tilman@imap.cc>
	<20090404-patch-02.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, hjlipp@web.de
To: tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46993
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757390AbZDGAnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 20:43:51 -0400
In-Reply-To: <20090404-patch-02.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Sun,  5 Apr 2009 18:39:33 +0200 (CEST)

> When the device is disconnected, the dev structure goes away, so
> trying to report another error via dev_printk is bound to oops.
> To avoid that, first check whether the device is still connected
> and return quietly if it isn't.
> 
> Impact: error handling
> 
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>
> Reported-by: Paul Bolle <pebolle@tiscali.nl>
> Tested-by: Paul Bolle <pebolle@tiscali.nl>

Applied.
