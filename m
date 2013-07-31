From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: [net PATCH] atl1c: Fix misuse of netdev_alloc_skb in refilling
 rx ring
Date: Wed, 31 Jul 2013 13:48:54 -0400
Message-ID: <20130731174854.GA27714@d2.synalogic.ca>
References: <87y58pva88.fsf@canonical.com>
 <1375111804.10515.1.camel@edumazet-glaptop>
 <1375118644.10515.18.camel@edumazet-glaptop>
 <20130730.191138.420648092010563209.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, luis.henriques@canonical.com,
	bhutchings@solarflare.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, jcliburn@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:53235 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752934Ab3GaRs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 13:48:59 -0400
Received: by mail-qc0-f179.google.com with SMTP id n10so477326qcx.10
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 10:48:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130730.191138.420648092010563209.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/07/30 19:11, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 29 Jul 2013 10:24:04 -0700
> 
> > [PATCH] atl1c: use custom skb allocator
> > 

BTW, this didn't end up in git with the intended patch subject. The
extra text prepended in the email also made it to the log.

7b70176 atl1c: Fix misuse of netdev_alloc_skb in refilling rx ring


> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
