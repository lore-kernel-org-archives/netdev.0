From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next v1 0/7] tipc: updates for neighbour
 monitor
Date: Tue, 20 Sep 2016 09:39:17 -0700
Message-ID: <20160920093917.7881af31@xeon-e3>
References: <1473693441-14254-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
        <jon.maloy@ericsson.com>, <maloy@donjonn.com>
To: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35736 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755170AbcITQjI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 12:39:08 -0400
Received: by mail-pf0-f181.google.com with SMTP id z123so9107088pfz.2
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 09:39:07 -0700 (PDT)
In-Reply-To: <1473693441-14254-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 Sep 2016 17:17:14 +0200
Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com> wrote:

> We add configuration support for the new link monitoring attributes.
> 
> Parthasarathy Bhuvaragan (7):
>   tipc: remove dead code
>   tipc: add link monitor set threshold
>   tipc: add link monitor get threshold
>   tipc: add link monitor summary
>   tipc: refractor bearer to facilitate link monitor
>   tipc: add link monitor list
>   tipc: update man page for link monitor
> 
>  man/man8/tipc-link.8 | 104 +++++++++++++
>  tipc/bearer.c        |  75 ++++++----
>  tipc/bearer.h        |   4 +
>  tipc/link.c          | 408 ++++++++++++++++++++++++++++++++++++++++++++++++++-
>  4 files changed, 556 insertions(+), 35 deletions(-)
> 

Applied, then I did a style scrub on tipc/link.c
