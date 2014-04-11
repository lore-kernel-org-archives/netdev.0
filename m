From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/3] mvneta: software TSO implementation
Date: Thu, 10 Apr 2014 18:02:30 -0700
Message-ID: <1397178150.16584.53.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1397170682-19138-1-git-send-email-ezequiel.garcia@free-electrons.com>
	 <20140410.205128.1312451576920196881.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ezequiel.garcia@free-electrons.com, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, simon.guinot@sequanux.org,
	w@1wt.eu, tawfik@marvell.com, alior@marvell.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:42809 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753957AbaDKBCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 21:02:32 -0400
Received: by mail-pd0-f170.google.com with SMTP id v10so4586812pde.15
        for <netdev@vger.kernel.org>; Thu, 10 Apr 2014 18:02:31 -0700 (PDT)
In-Reply-To: <20140410.205128.1312451576920196881.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-04-10 at 20:51 -0400, David Miller wrote:
> This is not really driver specific code.
> 
> Please create an appropriate abstraction, and put this code in a
> common place so that any driver can do this.
> 
> Thanks.

Note a prior implementation existed in

drivers/net/ethernet/tile/tilegx.c

Note sure how it can be properly factorized, but worth trying .
