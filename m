From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 2/4] tcpv6: trivial formatting changes to send_(ack|reset)
Date: Thu, 9 Oct 2008 12:58:07 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810091254160.1034@wrl-59.cs.helsinki.fi>
References: <1223544937-12595-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1223544937-12595-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20081009.185230.46697834.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-692940890-1223546287=:1034"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: "YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?="
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48295 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753824AbYJIJ6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 05:58:11 -0400
In-Reply-To: <20081009.185230.46697834.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-692940890-1223546287=:1034
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 9 Oct 2008, YOSHIFUJI Hideaki / ???? wrote:

> In article <1223544937-12595-2-git-send-email-ilpo.jarvinen@helsinki.fi> (at Thu,  9 Oct 2008 12:35:35 +0300), "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> says:
> 
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> > ---
> >  net/ipv6/tcp_ipv6.c |    7 +++----
> >  1 files changed, 3 insertions(+), 4 deletions(-)
> > 
> > diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> > index 2084f5a..3f268a3 100644
> > --- a/net/ipv6/tcp_ipv6.c
> > +++ b/net/ipv6/tcp_ipv6.c
> > @@ -948,7 +948,7 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
> >  	struct flowi fl;
> >  	struct net *net = dev_net(skb->dst->dev);
> >  	struct sock *ctl_sk = net->ipv6.tcp_sk;
> > -	unsigned int tot_len = sizeof(*th);
> > +	unsigned int tot_len = sizeof(struct tcphdr);
> >  #ifdef CONFIG_TCP_MD5SIG
> >  	struct tcp_md5sig_key *key;
> >  #endif
> 
> I usually prefer sizeof(var) (or sizeof(*ptr)) over sizeof(type).
> Could you justify this change?

My point was to make those two functions as equal as possible before merge 
so that it's more easier to track what happens at the merge, both 
versions pre-existed anyway. Sure I don't have much opinion either way.

-- 
 i.
---696208474-692940890-1223546287=:1034--
