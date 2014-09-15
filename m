From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] iproute: update dsfield file values
Date: Mon, 15 Sep 2014 13:52:48 +0200
Message-ID: <20140915135248.57954fff@redhat.com>
References: <20140914204353.5a0579be@urahara>
	<20140915130608.5d238cb1@redhat.com>
	<1410781699.7106.153.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42372 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753769AbaIOLw6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2014 07:52:58 -0400
In-Reply-To: <1410781699.7106.153.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Sep 2014 04:48:19 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Mon, 2014-09-15 at 13:06 +0200, Jesper Dangaard Brouer wrote:
> 
> > Is it a bug, that we put DSCP's Expedited Forwarding (EF) into the
> > best-effort priority band(1) in pfifo_fast???
> > 
> 
> With 3 bands pfifo_fast, its hard to please everyone.
> 
> Using 5 or 6 bands would be more generic ;)

We can easily fix it for EF (which should have gone into band 0).

But we should likely just ignore it for AFxx.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
