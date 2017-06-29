From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next v2 9/9] nfp: add control message passing
 capabilities to flower offloads
Date: Thu, 29 Jun 2017 18:21:53 +0300
Message-ID: <CAJ3xEMjhJYQTnFdHJuMcHR=n3MLa=+SAycVZ3ZCQbCWoU8EbJw@mail.gmail.com>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com> <1498681802-2897-10-git-send-email-simon.horman@netronome.com>
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
Received: from mail-oi0-f54.google.com ([209.85.218.54]:36838 "EHLO
        mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751974AbdF2PVy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 11:21:54 -0400
Received: by mail-oi0-f54.google.com with SMTP id p187so69223648oif.3
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 08:21:54 -0700 (PDT)
In-Reply-To: <1498681802-2897-10-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 28, 2017 at 11:30 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> +++ b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
> @@ -245,7 +245,11 @@ struct nfp_flower_cmsg_hdr {
>
>  /* Types defined for port related control messages  */
>  enum nfp_flower_cmsg_type_port {
> +       NFP_FLOWER_CMSG_TYPE_FLOW_ADD =         0,
> +       NFP_FLOWER_CMSG_TYPE_FLOW_MOD =         1,

AFAIU flower offload will always use delete and add and not modify,
if you think otherwise, would love to hear that. Didn't see you are using
the MOD define in the code anywhere.
