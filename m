From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v2 5/9] nfp: extend flower matching capabilities
Date: Thu, 29 Jun 2017 17:01:35 +0200
Message-ID: <20170629150134.GC6215@vergenet.net>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
 <1498681802-2897-6-git-send-email-simon.horman@netronome.com>
 <CAJ3xEMjoW=JdxEvwtDKU8mBtNEO=_Mdg8kv-jjn2hbDVCA4F6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:33069 "EHLO
        mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753394AbdF2PBm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 11:01:42 -0400
Received: by mail-qk0-f180.google.com with SMTP id r62so78488941qkf.0
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 08:01:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMjoW=JdxEvwtDKU8mBtNEO=_Mdg8kv-jjn2hbDVCA4F6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 29, 2017 at 05:31:22PM +0300, Or Gerlitz wrote:
> On Wed, Jun 28, 2017 at 11:29 PM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > +       /* Populate IPv4 frame. */
> > +       frame->reserved = 0;
> > +       frame->ipv4_src = flow_ipv4->src;
> > +       frame->ipv4_dst = flow_ipv4->dst;
> > +       frame->proto = flow_basic->ip_proto;
> > +       /* Wildcard TOS/TTL as TC can't match them yet. */
> 
> FWIW this is wrong... matching on both was added recently
> 
> > +       frame->tos = 0;
> > +       frame->ttl = 0;
> 
> note that the same flow dissector matching is used for ipv4 ttl/tos
> and ipv6 hoplimit/traffic class

Thanks. I think we'll update the comment for now and make use
of the nice new feature you added in a follow-up patchset.
