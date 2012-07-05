From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Create and use fib_compute_spec_dst() helper.
Date: Thu, 05 Jul 2012 10:10:21 +0200
Message-ID: <1341475821.2583.3362.camel@edumazet-glaptop>
References: <1341415267.2583.2120.camel@edumazet-glaptop>
	 <20120704.161335.1503971699878518173.davem@davemloft.net>
	 <1341474745.2583.3325.camel@edumazet-glaptop>
	 <20120705.005940.1078811938047681715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:63747 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754047Ab2GEIKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 04:10:25 -0400
Received: by eaak11 with SMTP id k11so3122238eaa.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 01:10:24 -0700 (PDT)
In-Reply-To: <20120705.005940.1078811938047681715.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-05 at 00:59 -0700, David Miller wrote:

> Yes, this is a great idea.  Actually in some obscure cases your
> change can cause us to compute it more than once I think.
> 
> I'd suggest we do something like create a helper function above this
> code in ip_options.c that checks whether spec_dst is INADDR_ANY or
> not, to guard computing it multiple times.
> 
> Could you put together a quick patch like that?

Sure I'll do that.
