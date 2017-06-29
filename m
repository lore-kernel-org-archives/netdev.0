From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next v2 9/9] nfp: add control message passing
 capabilities to flower offloads
Date: Thu, 29 Jun 2017 18:59:22 +0300
Message-ID: <CAJ3xEMhETYdrLaOFaGwGS9P+M+ZSa6h0pCXWx_fop-7+xzf2Zg@mail.gmail.com>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
 <1498681802-2897-10-git-send-email-simon.horman@netronome.com>
 <CAJ3xEMjhJYQTnFdHJuMcHR=n3MLa=+SAycVZ3ZCQbCWoU8EbJw@mail.gmail.com> <20170629153012.GE6215@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:34299 "EHLO
        mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751669AbdF2P7X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 11:59:23 -0400
Received: by mail-oi0-f42.google.com with SMTP id l130so15307674oib.1
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 08:59:23 -0700 (PDT)
In-Reply-To: <20170629153012.GE6215@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 29, 2017 at 6:30 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> On Thu, Jun 29, 2017 at 06:21:53PM +0300, Or Gerlitz wrote:
>> On Wed, Jun 28, 2017 at 11:30 PM, Simon Horman
>> <simon.horman@netronome.com> wrote:
>> > +++ b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
>> > @@ -245,7 +245,11 @@ struct nfp_flower_cmsg_hdr {
>> >
>> >  /* Types defined for port related control messages  */
>> >  enum nfp_flower_cmsg_type_port {
>> > +       NFP_FLOWER_CMSG_TYPE_FLOW_ADD =         0,
>> > +       NFP_FLOWER_CMSG_TYPE_FLOW_MOD =         1,
>>
>> AFAIU flower offload will always use delete and add and not modify,
>> if you think otherwise, would love to hear that. Didn't see you are using
>> the MOD define in the code anywhere.
>
> The firmware API has a mod operation but you are correct that
> we are not implementing that operation in this patch-set.

that wasn't my comment. I said that AFAIU flower will never ask you to
modify, they
will ask to delete and later add, so I would be happy to know if you
see it differently.
