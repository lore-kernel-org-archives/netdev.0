From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] bridge: add tracepoint in br_fdb_update
Date: Thu, 31 Aug 2017 15:43:44 -0700
Message-ID: <20170831154344.0a1f714e@xeon-e3>
References: <1504156693-24692-1-git-send-email-roopa@cumulusnetworks.com>
        <20170831.114325.2027598728601121750.davem@davemloft.net>
        <20170831235026.6377bf86@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, roopa@cumulusnetworks.com,
        netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
        f.fainelli@gmail.com, andrew@lunn.ch,
        bridge@lists.linux-foundation.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36480 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751205AbdHaWns (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 18:43:48 -0400
Received: by mail-pf0-f177.google.com with SMTP id r187so2801887pfr.3
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 15:43:47 -0700 (PDT)
In-Reply-To: <20170831235026.6377bf86@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 31 Aug 2017 23:50:26 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> On Thu, 31 Aug 2017 11:43:25 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Roopa Prabhu <roopa@cumulusnetworks.com>
> > Date: Wed, 30 Aug 2017 22:18:13 -0700
> >   
> > > From: Roopa Prabhu <roopa@cumulusnetworks.com>
> > > 
> > > This extends bridge fdb table tracepoints to also cover
> > > learned fdb entries in the br_fdb_update path. Note that
> > > unlike other tracepoints I have moved this to when the fdb
> > > is modified because this is in the datapath and can generate
> > > a lot of noise in the trace output. br_fdb_update is also called
> > > from added_by_user context in the NTF_USE case which is already
> > > traced ..hence the !added_by_user check.
> > > 
> > > Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>    
> > 
> > Applied.
> > 
> > Let's use dev->name for now and if the tooling can eventually
> > do transparent ifindex->name then we can consider redoing
> > a bunch of networking tracepoints.  
> 
> I agree! :-)
> 

Agreed, but it is yet another case of tracepoints not having
a stable ABI. There is no ABI guarantee on tracing, but it still
makes for user complaints.
