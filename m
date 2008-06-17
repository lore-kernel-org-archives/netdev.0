From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 2/2] ipv6: minor cleanup in net/ipv6/tcp_ipv6.c.
Date: Mon, 16 Jun 2008 17:08:37 -0700 (PDT)
Message-ID: <20080616.170837.147687281.davem@davemloft.net>
References: <eb3ff54b0806160209g62d8dec8h90756af506207e37@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47069
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754046AbYFQAIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 20:08:37 -0400
In-Reply-To: <eb3ff54b0806160209g62d8dec8h90756af506207e37@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Mon, 16 Jun 2008 12:09:31 +0300

> 2) Unify two consecutive #ifdef CONFIG_TCP_MD5SIG (with nothing in
>    between them) into one #ifdef CONFIG_TCP_MD5SIG.

I think there should be an empty line between local variable
declarations and actual code in a function.  Please fix this
up, thanks.

