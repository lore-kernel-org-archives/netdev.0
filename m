From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] net: netfilter: remove unused variable
Date: Thu, 30 Mar 2017 16:36:41 +0200
Message-ID: <20170330143641.GA999@salvia>
References: <20170329145752.GA2756@arushi-HP-Pavilion-Notebook>
 <20170330125509.GD2980@verge.net.au>
 <CA+XqjF_pbKoYC+UM9ad2wOvBo6gNnEEWnrUjJHfuDcFx3jEEzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <horms@verge.net.au>,
        outreachy-kernel@googlegroups.com,
        Wensong Zhang <wensong@linux-vs.org>,
        Julian Anastasov <ja@ssi.bg>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, LKML <linux-kernel@vger.kernel.org>
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41024 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933862AbdC3Ogt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 30 Mar 2017 10:36:49 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id E011E24612
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 16:36:44 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D06D3DA38B
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 16:36:44 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 554E4DA878
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 16:36:41 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <CA+XqjF_pbKoYC+UM9ad2wOvBo6gNnEEWnrUjJHfuDcFx3jEEzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 30, 2017 at 07:38:08PM +0530, Arushi Singhal wrote:
> On Thu, Mar 30, 2017 at 6:25 PM, Simon Horman <horms@verge.net.au> wrote:
> 
> > On Wed, Mar 29, 2017 at 08:27:52PM +0530, Arushi Singhal wrote:
> > > This patch uses the following coccinelle script to remove
> > > a variable that was simply used to store the return
> > > value of a function call before returning it:
> > >
> > > @@
> > > identifier len,f;
> > > @@
> > >
> > > -int len;
> > >  ... when != len
> > >      when strict
> > > -len =
> > > +return
> > >         f(...);
> > > -return len;
> > >
> > > Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
> >
> > Applied with patch prefix updated to "ipvs:".
> >
> Hi
> Thanks
> How can I see my accepted patches of netfilter.

You can use links from patchwork:

http://patchwork.ozlabs.org/project/netfilter-devel/
