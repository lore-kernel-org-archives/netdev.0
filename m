From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next v2 0/3] Add support for SRv6 local
 segment processing
Date: Tue, 15 Aug 2017 16:45:25 -0700
Message-ID: <20170815164525.1a67d1e6@xeon-e3>
References: <20170809153326.29599-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:35858 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751095AbdHOXpc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 19:45:32 -0400
Received: by mail-pg0-f42.google.com with SMTP id i12so14767175pgr.3
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 16:45:32 -0700 (PDT)
In-Reply-To: <20170809153326.29599-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Aug 2017 17:33:23 +0200
David Lebrun <david.lebrun@uclouvain.be> wrote:

> This patch series adds support and documentation for the seg6local
> lightweight tunnel, enabling to perform operations to SR-enabled packets
> based on their active segment.
> 
> v2: use a table for action names
> 
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
> 
> David Lebrun (3):
>   iproute: add helper functions for SRH processing
>   iproute: add support for SRv6 local segment processing
>   man: add documentation for seg6local lwt
> 
>  ip/iproute.c           |   2 +-
>  ip/iproute_lwtunnel.c  | 324 +++++++++++++++++++++++++++++++++++++++++--------
>  man/man8/ip-route.8.in |  62 +++++++++-
>  3 files changed, 338 insertions(+), 50 deletions(-)
> 

Applied to net-next branch.
Thanks David.
