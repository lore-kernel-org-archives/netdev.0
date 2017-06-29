From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v2 9/9] nfp: add control message passing
 capabilities to flower offloads
Date: Thu, 29 Jun 2017 17:30:14 +0200
Message-ID: <20170629153012.GE6215@vergenet.net>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
 <1498681802-2897-10-git-send-email-simon.horman@netronome.com>
 <CAJ3xEMjhJYQTnFdHJuMcHR=n3MLa=+SAycVZ3ZCQbCWoU8EbJw@mail.gmail.com>
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
Received: from mail-qk0-f181.google.com ([209.85.220.181]:35002 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753343AbdF2Pa0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 11:30:26 -0400
Received: by mail-qk0-f181.google.com with SMTP id 16so79302217qkg.2
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 08:30:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMjhJYQTnFdHJuMcHR=n3MLa=+SAycVZ3ZCQbCWoU8EbJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 29, 2017 at 06:21:53PM +0300, Or Gerlitz wrote:
> On Wed, Jun 28, 2017 at 11:30 PM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > +++ b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
> > @@ -245,7 +245,11 @@ struct nfp_flower_cmsg_hdr {
> >
> >  /* Types defined for port related control messages  */
> >  enum nfp_flower_cmsg_type_port {
> > +       NFP_FLOWER_CMSG_TYPE_FLOW_ADD =         0,
> > +       NFP_FLOWER_CMSG_TYPE_FLOW_MOD =         1,
> 
> AFAIU flower offload will always use delete and add and not modify,
> if you think otherwise, would love to hear that. Didn't see you are using
> the MOD define in the code anywhere.

The firmware API has a mod operation but you are correct that
we are not implementing that operation in this patch-set.
