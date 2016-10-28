From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 3/9] ipv6: sr: add support for SRH encapsulation
 and injection with lwtunnels
Date: Fri, 28 Oct 2016 05:59:56 -0700
Message-ID: <58134BCC.90707@cumulusnetworks.com>
References: <1477575239-11228-1-git-send-email-david.lebrun@uclouvain.be> <1477575239-11228-4-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:32881 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759149AbcJ1M77 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 08:59:59 -0400
Received: by mail-pf0-f178.google.com with SMTP id 197so37645744pfu.0
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 05:59:59 -0700 (PDT)
In-Reply-To: <1477575239-11228-4-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/16, 6:33 AM, David Lebrun wrote:
> This patch creates a new type of interfaceless lightweight tunnel (SEG6),
> enabling the encapsulation and injection of SRH within locally emitted
> packets and forwarded packets.
>
> From a configuration viewpoint, a seg6 tunnel would be configured as follows:
>
>   ip -6 ro ad fc00::1/128 encap seg6 mode encap segs fc42::1,fc42::2,fc42::3 dev eth0
>
> Any packet whose destination address is fc00::1 would thus be encapsulated
> within an outer IPv6 header containing the SRH with three segments, and would
> actually be routed to the first segment of the list. If `mode inline' was
> specified instead of `mode encap', then the SRH would be directly inserted
> after the IPv6 header without outer encapsulation.
>
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
