From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v2 0/3] Covscan: Fixes for obvious programming
 mistakes
Date: Fri, 18 Aug 2017 09:15:34 -0700
Message-ID: <20170818091534.6f89fc5c@xeon-e3>
References: <20170817170932.24812-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:33583 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750846AbdHRQPn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 12:15:43 -0400
Received: by mail-pg0-f44.google.com with SMTP id t3so39207020pgt.0
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 09:15:42 -0700 (PDT)
In-Reply-To: <20170817170932.24812-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Aug 2017 19:09:29 +0200
Phil Sutter <phil@nwl.cc> wrote:

> This series collects those patches from v1 which are clear programming
> flaws.
> 
> No changes to the actual patches, just splitting into smaller series.
> 
> Phil Sutter (3):
>   iproute_lwtunnel: csum_mode value checking was ineffective
>   iproute_lwtunnel: Argument to strerror must be positive
>   tipc/node: Fix socket fd check in cmd_node_get_addr()
> 
>  ip/iproute_lwtunnel.c | 9 +++++----
>  tipc/node.c           | 3 ++-
>  2 files changed, 7 insertions(+), 5 deletions(-)
> 

Accepted.
