From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Wed, 2 Sep 2009 09:33:29 +0000
Message-ID: <20090902093329.GB6530@ff.dom.local>
References: <20090902081429.GB4878@ff.dom.local> <4A9E2CC7.1010103@gmail.com> <20090902091854.GA6530@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Lameter <cl@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:20647 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753113AbZIBJdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 05:33:32 -0400
Received: by fg-out-1718.google.com with SMTP id 22so331845fge.1
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2009 02:33:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090902091854.GA6530@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 02, 2009 at 09:18:54AM +0000, Jarek Poplawski wrote:
> On Wed, Sep 02, 2009 at 10:28:55AM +0200, Eric Dumazet wrote:
...
> > qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> > 
> > 
> > Same name "eth0" is displayed, that might confuse parsers...
> > 
> > What naming convention should we choose for multiqueue devices ?
> > 
> 
> Hmm... anything could break here something for somebody, so there is
> still a (Patrick's) question if not sum it all? Otherwise, I wonder
> about using the qdisc handle (tcm_handle>>16): there would be at
> least one "pfifo_fast 0:" looking like proper root for somebody...

I meant "proper" for pfifo_fast. On the other hand, I wonder why these
multiqueue qdisc handles can't be really given such unique per dev
(instead of per queue) handles?

Jarek P.
