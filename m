From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sfc: Convert the normal transmit complete path
 to dev_consume_skb_any()
Date: Tue, 09 Sep 2014 17:25:30 -0700
Message-ID: <1410308730.7106.23.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140909214327.D474F290042C@tardy>
	 <1410304704.7106.22.camel@edumazet-glaptop2.roam.corp.google.com>
	 <540F8F78.9020502@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <raj@tardy.usa.hp.com>, netdev@vger.kernel.org,
	davem@davemloft.net, sshah@solarflare.com,
	linux-net-drivers@solarflare.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:64324 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbaIJAZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 20:25:31 -0400
Received: by mail-pd0-f181.google.com with SMTP id w10so4970175pde.26
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 17:25:31 -0700 (PDT)
In-Reply-To: <540F8F78.9020502@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-09 at 16:38 -0700, Rick Jones wrote:

> I can remove that const, and then smooth the ripples stemming from it to 
> arrive at something like:

Oh I missed this const, so this will be a different patch, sorry for
this.

Acked-by: Eric Dumazet <edumazet@google.com>
