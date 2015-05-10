From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/2 net-next] net: move qdisc ingress filtering code
 where it belongs
Date: Sun, 10 May 2015 21:20:44 +0200
Message-ID: <20150510192044.GA7173@salvia>
References: <1431277170-4618-1-git-send-email-pablo@netfilter.org>
 <1431277170-4618-3-git-send-email-pablo@netfilter.org>
 <554F9946.9040707@plumgrid.com>
 <20150510175934.GA3799@salvia>
 <554F9DE8.3000507@plumgrid.com>
 <20150510182414.GA4198@salvia>
 <554FA7A5.5020400@plumgrid.com>
 <20150510190039.GA4938@salvia>
 <554FAC3A.40701@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	daniel@iogearbox.net
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51638 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751743AbbEJTP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 May 2015 15:15:59 -0400
Content-Disposition: inline
In-Reply-To: <554FAC3A.40701@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 10, 2015 at 12:06:34PM -0700, Alexei Starovoitov wrote:
> On 5/10/15 12:00 PM, Pablo Neira Ayuso wrote:
> >
> >The inlined code into the ingress core path seems to have an impact to
> >people that don't need this, even with the static key.
> 
> two emails ago you've accused me of non-technical comments and
> now I've posted real numbers that show no impact on users that don't
> enable ingress and you still say 'seems to have an impact' ?!
> I'm speechless.

No. On the danger of repeating myself: The existing approach that
inlines handle_ing() into __netif_receive_skb_core(), and your
approach since it's persists on that, has an impact in performance on
everyone in the earth.

It's quite clear from my patchset description.
