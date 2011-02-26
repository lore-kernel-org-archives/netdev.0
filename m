From: David Miller <davem@davemloft.net>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Fri, 25 Feb 2011 23:46:00 -0800 (PST)
Message-ID: <20110225.234600.183054936.davem@davemloft.net>
References: <20110225.190723.39180243.davem@davemloft.net>
	<20110226031118.GA21270@gondor.apana.org.au>
	<1298705484.2659.126.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, rick.jones2@hp.com,
	tgraf@infradead.org, therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44524
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751518Ab1BZHpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Feb 2011 02:45:24 -0500
In-Reply-To: <1298705484.2659.126.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 26 Feb 2011 08:31:24 +0100

> UDP CORK is a problem indeed. I wonder who really uses it ?

git grep MSG_MORE -- net/sunrpc

