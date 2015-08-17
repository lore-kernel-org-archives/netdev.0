From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/2] net: introduce IFF_NO_QUEUE as successor of zero
 tx_queue_len
Date: Mon, 17 Aug 2015 06:44:51 -0700
Message-ID: <1439819091.7258.19.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439485268-20953-1-git-send-email-phil@nwl.cc>
	 <20150813104950.1b8346f2@urahara> <20150813204037.3c4e68a4@redhat.com>
	 <20150813121157.5166efb1@urahara> <20150814084153.GI32353@orbit.nwl.cc>
	 <20150817085121.419a1d28@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net, fw@strlen.de, cwang@twopensource.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35250 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754995AbbHQNow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 09:44:52 -0400
Received: by pacgr6 with SMTP id gr6so109068442pac.2
        for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 06:44:52 -0700 (PDT)
In-Reply-To: <20150817085121.419a1d28@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-08-17 at 08:51 +0200, Jesper Dangaard Brouer wrote:
> On Fri, 14 Aug 2015 10:41:53 +0200 Phil Sutter <phil@nwl.cc> wrote:
> 
> > On Thu, Aug 13, 2015 at 12:11:57PM -0700, Stephen Hemminger wrote:
> [...]
> > > 
> > > But adding a flag risks breaking external scripts.
> > 
> > Could you please elaborate on this? As far as I can tell, introducing a
> > separate flag is the only solution *not* breaking existing scripts. So
> > if you see the rub, I would like to know where exactly it is.
> 
> I agree with Phil.  AFAIC see this approach does not break existing
> scripts.
> 
> Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
> 

But, what is the long term plan ?

If long term plan is to change veth txqueuelen to 0, we said no.
(because it is too late and this change will break some setups)

If not, this flag wont help the case you want to optimize anyway.

(ie : veth with no qdisc)

So really, _new_ user scripts should either: make sure a qdisc is not
there, or is there.

Relying on a new flag wont help.

There is no point adding this flag as such if we do not take proper
decisions.
