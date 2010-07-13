From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] inet, inet6: make tcp_sendmsg() and tcp_sendpage()
 through inet_sendmsg() and inet_sendpage()
Date: Mon, 12 Jul 2010 20:35:07 -0700 (PDT)
Message-ID: <20100712.203507.267966739.davem@davemloft.net>
References: <1278830515-22422-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, therbert@google.com,
	netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41469
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753519Ab0GMDew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 23:34:52 -0400
In-Reply-To: <1278830515-22422-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Sun, 11 Jul 2010 14:41:55 +0800

> inet, inet6: make tcp_sendmsg() and tcp_sendpage() through inet_sendmsg() and
> inet_sendpage()
> 
> a new boolean flag no_autobind is added to structure proto to avoid the autobind
> calls when the protocol is TCP. Then sock_rps_record_flow() is called int the
> TCP's sendmsg() and sendpage() pathes.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied.
