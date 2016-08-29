From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [RFC 2/9] ipv6: sr: add code base for control plane support of
 SR-IPv6
Date: Mon, 29 Aug 2016 08:31:27 -0700
Message-ID: <57C4554F.9000905@cumulusnetworks.com>
References: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be> <1472226767-9904-3-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35274 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757647AbcH2Pba (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 11:31:30 -0400
Received: by mail-pf0-f177.google.com with SMTP id x72so53197653pfd.2
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 08:31:30 -0700 (PDT)
In-Reply-To: <1472226767-9904-3-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/26/16, 8:52 AM, David Lebrun wrote:
> This patch adds the necessary hooks and structures to provide support
> for SR-IPv6 control plane, essentially the Generic Netlink commands
> that will be used for userspace control over the Segment Routing
> kernel structures.
>
> The genetlink commands provide control over two different structures:
> tunnel source and HMAC data. The tunnel source is the source address
> that will be used by default when encapsulating packets into an
> outer IPv6 header + SRH. If the tunnel source is set to :: then an
> address of the outgoing interface will be selected as the source.
>
> The HMAC commands currently just return ENOTSUPP and will be implemented
> in a future patch.
>
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
>
This looks fine. But, i am just trying to see if this can be rtnetlink.
Have you considered it already ?.
We would like to keep the API consistent or abstracted to accommodate SR-MPLS in the
future too. so, any abstraction there will help.

what is your control-plane software using this ?
quagga or any-other routing daemon ?

Thanks,
Roopa
