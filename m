From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] neighbour: update neigh timestamps iff update is
 effective
Date: Tue, 16 May 2017 01:27:52 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1705160114010.8760@ja.home.ssi.bg>
References: <20170510000605.6799-1-ihrachys@redhat.com> <alpine.LFD.2.20.1705152234490.4002@ja.home.ssi.bg> <CAKwN9=C-_F-8GQ7yMO6wVR1Ukw3gCBYOzxxDRRLU9b-u9P1v-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
        He Chunhui <hchunhui@mail.ustc.edu.cn>, netdev@vger.kernel.org
To: Ihar Hrachyshka <ihrachys@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:57766 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751253AbdEOW20 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 15 May 2017 18:28:26 -0400
In-Reply-To: <CAKwN9=C-_F-8GQ7yMO6wVR1Ukw3gCBYOzxxDRRLU9b-u9P1v-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 15 May 2017, Ihar Hrachyshka wrote:

> On Mon, May 15, 2017 at 1:05 PM, Julian Anastasov <ja@ssi.bg> wrote:
> >
> >         It seems arp_accept value currently has influence on
> > the locktime for GARP requests. My understanding is that
> > locktime is used to ignore replies from proxy_arp
> > routers while the requested IP is present on the LAN
> > and replies immediately. IMHO, GARP requests should not
> > depend on locktime, even when arp_accept=0. For example:
> 
> Yes, I believe so.
> 
> I actually thought about introducing the patch that does just that:
> forcing override on garp, but then I was thinking, maybe there is some
> reason to still apply locktime rules to garps; f.e. if you have
> multiple nodes carrying the ip address and located on the same
> segment, maybe you want to pick the first that replies to you (in
> theory, it may be the node that is less loaded, or closer to us; but
> then, it's so fragile even if that was the intent...) Do you want me
> to post the patch, or will you cover it?

	Feel free to post a patch for this, I see that you change
in another patch the is_garp value, so it seems the same logic
should be used twice.

Regards
