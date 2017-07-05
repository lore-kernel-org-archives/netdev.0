From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH net] net: ipv6: Compare lwstate in detecting duplicate
 nexthops
Date: Thu, 6 Jul 2017 00:38:46 +0300
Message-ID: <20170705213846.GP22185@wantstofly.org>
References: <20170705204146.5263-1-dsahern@gmail.com>
 <CAJieiUji4hOeRXZoCXfiC6p5NYzeqO_Ou0RYzarX2afXgLzcqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Robert Shearman <rshearma@brocade.com>
To: David Ahern <dsahern@gmail.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hmm.wantstofly.org ([138.201.34.84]:41544 "EHLO
        mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751744AbdGEVis (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 17:38:48 -0400
Content-Disposition: inline
In-Reply-To: <CAJieiUji4hOeRXZoCXfiC6p5NYzeqO_Ou0RYzarX2afXgLzcqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 05, 2017 at 02:14:33PM -0700, Roopa Prabhu wrote:

> > Lennert reported a failure to add different mpls encaps in a multipath
> > route:
> >
> >   $ ip -6 route add 1234::/16 \
> >         nexthop encap mpls 10 via fe80::1 dev ens3 \
> >         nexthop encap mpls 20 via fe80::1 dev ens3
> >   RTNETLINK answers: File exists
> >
> > The problem is that the duplicate nexthop detection does not compare
> > lwtunnel configuration. Add it.
> >
> > Fixes: 19e42e451506("ipv6: support for fib route lwtunnel encap attributes")
> > Signed-off-by: David Ahern <dsahern@gmail.com>
> 
> Reported-by: João Taveira Araújo <joao.taveira@gmail.com>
> 
> Reported-by: Lennert Buytenhek <buytenh@wantstofly.org>
> 
> Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Tested-by: Lennert Buytenhek <buytenh@wantstofly.org>

Seems to work!  Thanks!
