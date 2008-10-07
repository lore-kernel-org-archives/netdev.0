From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [net-next PATCH] Add udplib_lookup_skb() helpers (was:
	[net-next PATCH 10/16] Don't lookup the socket if there's a socket
	attached to the skb)
Date: Tue, 7 Oct 2008 09:34:54 -0300
Message-ID: <20081007123453.GA29610@ghostprotocols.net>
References: <20081001142431.4893.69772.stgit@este> <20081001.075040.135314845.davem@davemloft.net> <1222875500.7492.6.camel@este> <20081001.085104.193726318.davem@davemloft.net> <1222962200.14079.19.camel@este> <20081002170935.GE17843@ghostprotocols.net> <1223024268.8912.2.camel@este> <20081003134747.GH17843@ghostprotocols.net> <1223365332.35518.9.camel@nessa.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: KOVACS Krisztian <hidden@sch.bme.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33330 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753241AbYJGMiN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2008 08:38:13 -0400
Content-Disposition: inline
In-Reply-To: <1223365332.35518.9.camel@nessa.odu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Oct 07, 2008 at 09:42:12AM +0200, KOVACS Krisztian escreveu:
> Hi,
> 
> On Fri, 2008-10-03 at 10:47 -0300, Arnaldo Carvalho de Melo wrote:
> > > Those functions don't have access to the skb so unless we change the
> > > signature they won't be able to steal the reference.
> > 
> > Indeed, but we should try to have the main TCP code flow clean, ditto
> > for
> > DCCP, free of such details, so after this activitity settles down I'll
> > submit something like the patch below.
> > 
> > If Dave agrees and you feel like merging it on your current patchset,
> > feel free to do it.
> 
> And here are the skb lookup helpers for UDP.

Thanks!

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
