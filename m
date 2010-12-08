From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: protect sysctl_tcp_cookie_size reads
Date: Wed, 08 Dec 2010 12:35:55 -0800 (PST)
Message-ID: <20101208.123555.242141029.davem@davemloft.net>
References: <1291755776.21627.13.camel@bwh-desktop>
	<1291757288.5324.18.camel@edumazet-laptop>
	<1291760447.5324.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Martin@lichtvoll.de, netdev@vger.kernel.org,
	bhutchings@solarflare.com, william.allen.simpson@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47054
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755453Ab0LHUf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 15:35:28 -0500
In-Reply-To: <1291760447.5324.31.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 07 Dec 2010 23:20:47 +0100

> Make sure sysctl_tcp_cookie_size is read once in
> tcp_cookie_size_check(), or we might return an illegal value to caller
> if sysctl_tcp_cookie_size is changed by another cpu.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
