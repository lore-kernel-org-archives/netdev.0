From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Multicast routing stops functioning after 4G multicast packets
 recived.
Date: Sun, 12 Jan 2014 16:56:00 -0800
Message-ID: <1389574560.31367.197.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140109201411.317040@gmx.com>
	 <20140110063638.GA17866@order.stressinduktion.org>
	 <1389337306.31367.94.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140110071049.GB17866@order.stressinduktion.org>
	 <1389339179.31367.98.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140110074325.GC17866@order.stressinduktion.org>
	 <20140110075005.GD17866@order.stressinduktion.org>
	 <20140112074245.GF6586@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Bob Falken <NetFestivalHaveFun@gmx.com>,
	Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org,
	kaber@trash.net, tgraf@suug.ch
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:37300 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbaAMA4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 19:56:02 -0500
Received: by mail-pb0-f44.google.com with SMTP id rq2so6680773pbb.3
        for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 16:56:01 -0800 (PST)
In-Reply-To: <20140112074245.GF6586@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-01-12 at 08:42 +0100, Hannes Frederic Sowa wrote:

> Hm, Eric. If we do that we can just specifiy FIB_LOOKUP_NOREF
> unconditionally. FIB_LOOKUP_NOREF has no other side effects on a ipmr
> lookup as taking the reference on the rule, which we would drop after
> that.
> 
> So we would actually be going back to the first patch in this thread. I
> guess it is just a matter of style?

Hi Hannes, please submit a formal patch, so that we can have a proper
ground for discussion (I guess I'll only add my Acked-by)

Thanks !
