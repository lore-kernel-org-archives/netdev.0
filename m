From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH] atl1c: Fix misuse of netdev_alloc_skb in refilling
 rx ring
Date: Wed, 31 Jul 2013 10:56:30 -0700
Message-ID: <1375293390.10515.107.camel@edumazet-glaptop>
References: <87y58pva88.fsf@canonical.com>
	 <1375111804.10515.1.camel@edumazet-glaptop>
	 <1375118644.10515.18.camel@edumazet-glaptop>
	 <20130730.191138.420648092010563209.davem@davemloft.net>
	 <20130731174854.GA27714@d2.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, luis.henriques@canonical.com,
	bhutchings@solarflare.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, jcliburn@gmail.com
To: Benjamin Poirier <benjamin.poirier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f179.google.com ([209.85.160.179]:63043 "EHLO
	mail-gh0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752934Ab3GaR4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 13:56:34 -0400
Received: by mail-gh0-f179.google.com with SMTP id f16so377442ghb.24
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 10:56:34 -0700 (PDT)
In-Reply-To: <20130731174854.GA27714@d2.synalogic.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-31 at 13:48 -0400, Benjamin Poirier wrote:
> On 2013/07/30 19:11, David Miller wrote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Mon, 29 Jul 2013 10:24:04 -0700
> > 
> > > [PATCH] atl1c: use custom skb allocator
> > > 
> 
> BTW, this didn't end up in git with the intended patch subject. The
> extra text prepended in the email also made it to the log.
> 
> 7b70176 atl1c: Fix misuse of netdev_alloc_skb in refilling rx ring

True, but its not a problem, as long as the bug is fixed ;)
