From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] flowcache: Fix resource leaks on namespace
 exit.
Date: Wed, 12 Mar 2014 04:43:40 -0700
Message-ID: <1394624620.21721.43.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1394424146.3607.2.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1394424557.3607.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140310131909.33a3042c@north>
	 <1394460276.3607.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140311014649.1716bde1@north> <20140311120059.GB32371@secunet.com>
	 <1394541626.21721.24.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140311132030.GD32371@secunet.com> <20140311153029.1de9d6e9@north>
	 <20140312083827.GE32371@secunet.com> <20140312084317.GF32371@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jakub =?UTF-8?Q?Kici=C5=84ski?= <moorray3@wp.pl>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Fan Du <fan.du@windriver.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:52836 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753414AbaCLLnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 07:43:42 -0400
Received: by mail-pa0-f50.google.com with SMTP id kq14so994186pab.9
        for <netdev@vger.kernel.org>; Wed, 12 Mar 2014 04:43:42 -0700 (PDT)
In-Reply-To: <20140312084317.GF32371@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-03-12 at 09:43 +0100, Steffen Klassert wrote:
> We leak an active timer, the hotcpu notifier and all allocated
> resources when we exit a namespace. Fix this by introducing a
> flow_cache_fini() function where we release the resources before
> we exit.
> 
> Fixes: ca925cf1534e ("flowcache: Make flow cache name space aware")
> Reported-by: Jakub Kicinski <moorray3@wp.pl>
> Tested-by: Jakub Kicinski <moorray3@wp.pl>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Fan Du <fan.du@windriver.com>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
