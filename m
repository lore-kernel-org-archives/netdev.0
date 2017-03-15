From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] net/gtp: Add udp source port generation
 according to flow hash
Date: Wed, 15 Mar 2017 17:25:41 +0100
Message-ID: <20170315162541.GA29639@salvia>
References: <635223204.206529.1487859673545.JavaMail.zimbra@tpip.net>
 <20170223164229.GA4996@salvia>
 <109485900.208950.1487870356640.JavaMail.zimbra@tpip.net>
 <20170223.125401.1794857404908689667.davem@davemloft.net>
 <CAJ3xEMiF_T_JxTik+yxvYoBQCiG=kKzukSsORApKB9nhTSvqeQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Andreas Schultz <aschultz@tpip.net>,
        Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        laforge <laforge@gnumonks.org>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48172 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750780AbdCOQZr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 12:25:47 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 18BB0FB45D
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 17:25:44 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 086BDDA87C
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 17:25:44 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B2179DA874
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 17:25:41 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMiF_T_JxTik+yxvYoBQCiG=kKzukSsORApKB9nhTSvqeQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 15, 2017 at 06:14:02PM +0200, Or Gerlitz wrote:
> On Thu, Feb 23, 2017 at 7:54 PM, David Miller <davem@davemloft.net> wrote:
> > From: Andreas Schultz <aschultz@tpip.net>
> > Date: Thu, 23 Feb 2017 18:19:16 +0100 (CET)
> >
> >> When we are talking about the xmit path, then currently none of the
> >> receivers we are talking to is going to be Linux and we have no
> >> idea how they will behave nor do we have any influence on them. Do
> >> we really need to make assumptions about other vendors implementations?
> >>
> >> Traces on live GRX networks show that about 90% of the SGSN/S-GW
> >> that would talk to us always use the default GTP-U port as source
> >> port. Some multi chassis GSN's seem to assign source port ranges to
> >> chassis, but that has nothing todo with DDOS protection.
> >
> > This is exactly what other UDP tunnel implementations did before
> > flow separation was prevelant.
> >
> > I don't see the point of any of this discussion discouraging the
> > enablement of proper flow separation.
> 
> Hi Dave,
> 
> So where do we  go from here? should I resubmit the patch?

IIRC this patch didn't get into the merge window in time, so it's
reasonable to resubmit I think.

You may want to add this to the patch:

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>

Thanks Or.
