From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix struct sock bitfield annotation
Date: Sun, 11 Oct 2009 23:07:30 -0700 (PDT)
Message-ID: <20091011.230730.42254718.davem@davemloft.net>
References: <4ACE8CEC.3020905@gmail.com>
	<20091009.005408.151610125.davem@davemloft.net>
	<4ACEF951.7030104@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vegard.nossum@gmail.com, netdev@vger.kernel.org, mingo@elte.hu
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36830
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753813AbZJLGHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 02:07:35 -0400
In-Reply-To: <4ACEF951.7030104@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 09 Oct 2009 10:50:25 +0200

> [PATCH] net: Fix struct sock bitfield annotation
> 
> Since commit a98b65a3 (net: annotate struct sock bitfield), we lost
> 8 bytes in struct sock on 64bit arches because of 
> kmemcheck_bitfield_end(flags) misplacement.
> 
> Fix this by putting together sk_shutdown, sk_no_check, sk_userlocks,
> sk_protocol and sk_type in the 'flags' 32bits bitfield
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
