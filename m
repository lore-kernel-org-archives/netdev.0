From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] [ipv4] remove unused declaration from
 include/net/tcp.h.
Date: Tue, 10 Jun 2008 12:38:32 -0700 (PDT)
Message-ID: <20080610.123832.230112448.davem@davemloft.net>
References: <eb3ff54b0806100614o26981c8ao5b1fb952f7b843fa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45592
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757298AbYFJTic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 15:38:32 -0400
In-Reply-To: <eb3ff54b0806100614o26981c8ao5b1fb952f7b843fa@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Tue, 10 Jun 2008 16:14:24 +0300

> - The tcp_unhash() method in /include/net/tcp.h is no more needed, as the
> unhash method in tcp_prot structure is now inet_unhash (instead of
> tcp_unhash in the
> past); see tcp_prot structure in net/ipv4/tcp_ipv4.c.
> 
> - So, this patch removes tcp_unhash() declaration from include/net/tcp.h
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks Rami.

Please read:

http://marc.info/?l=linux-netdev&m=121262022428660&w=2

for a desciption of how I'd like commit header lines to
be formulated.  In this patch's case it should have been
"ipv4: remove unused..." instead of "[ipv4] remove unused..."

Thanks.
