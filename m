From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] iproute: update dsfield file values
Date: Mon, 15 Sep 2014 05:23:05 -0700
Message-ID: <1410783785.7106.154.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140914204353.5a0579be@urahara>
	 <20140915130608.5d238cb1@redhat.com>
	 <1410781699.7106.153.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140915135248.57954fff@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35042 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794AbaIOMXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 08:23:07 -0400
Received: by mail-pa0-f48.google.com with SMTP id hz1so6365792pad.35
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 05:23:05 -0700 (PDT)
In-Reply-To: <20140915135248.57954fff@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-15 at 13:52 +0200, Jesper Dangaard Brouer wrote:
> On Mon, 15 Sep 2014 04:48:19 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Mon, 2014-09-15 at 13:06 +0200, Jesper Dangaard Brouer wrote:
> > 
> > > Is it a bug, that we put DSCP's Expedited Forwarding (EF) into the
> > > best-effort priority band(1) in pfifo_fast???
> > > 
> > 
> > With 3 bands pfifo_fast, its hard to please everyone.
> > 
> > Using 5 or 6 bands would be more generic ;)
> 
> We can easily fix it for EF (which should have gone into band 0).
> 
> But we should likely just ignore it for AFxx.
> 

Yep, please submit a patch.
