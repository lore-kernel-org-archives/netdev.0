From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] Add udplib_lookup_skb() helpers
Date: Tue, 07 Oct 2008 12:39:13 -0700 (PDT)
Message-ID: <20081007.123913.120584527.davem@davemloft.net>
References: <20081003134747.GH17843@ghostprotocols.net>
	<1223365332.35518.9.camel@nessa.odu>
	<20081007123453.GA29610@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hidden@sch.bme.hu, kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39494
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752752AbYJGTji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 15:39:38 -0400
In-Reply-To: <20081007123453.GA29610@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 7 Oct 2008 09:34:54 -0300

> Em Tue, Oct 07, 2008 at 09:42:12AM +0200, KOVACS Krisztian escreveu:
> > Hi,
> > 
> > On Fri, 2008-10-03 at 10:47 -0300, Arnaldo Carvalho de Melo wrote:
> > > > Those functions don't have access to the skb so unless we change the
> > > > signature they won't be able to steal the reference.
> > > 
> > > Indeed, but we should try to have the main TCP code flow clean, ditto
> > > for
> > > DCCP, free of such details, so after this activitity settles down I'll
> > > submit something like the patch below.
> > > 
> > > If Dave agrees and you feel like merging it on your current patchset,
> > > feel free to do it.
> > 
> > And here are the skb lookup helpers for UDP.
> 
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied to net-next-2.6
