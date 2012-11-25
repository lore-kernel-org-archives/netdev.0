From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] ipv4: ipmr: various fixes and cleanups
Date: Sun, 25 Nov 2012 10:27:03 -0800
Message-ID: <1353868023.6558.10.camel@joe-AO722>
References: <1353861705.30446.675.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:45979 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753246Ab2KYS1E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Nov 2012 13:27:04 -0500
In-Reply-To: <1353861705.30446.675.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-11-25 at 08:41 -0800, Eric Dumazet wrote:
> 4) " (v) ? 1 : 0 " can be written as " !!v "

Or maybe the compiler could do it by changing
mroute_do_assert and mroute_do_pim to bool to
save a few bytes per table too.
