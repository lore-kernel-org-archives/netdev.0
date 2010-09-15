From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] X.25 remove bkl in listen
Date: Tue, 14 Sep 2010 20:40:17 -0700 (PDT)
Message-ID: <20100914.204017.226779854.davem@davemloft.net>
References: <1284507076.1742.51.camel@jaunty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew.hendry@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37261
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752206Ab0IODj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 23:39:59 -0400
In-Reply-To: <1284507076.1742.51.camel@jaunty>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Hendry <andrew.hendry@gmail.com>
Date: Wed, 15 Sep 2010 09:31:16 +1000

> Listen updates socket values and needs lock_sock.
> 
> Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

Applied.

Although you may want to think about whether we need to also hold the
x25_list_lock as a writer here so that scanners of the socket list see
consistent state changes.
