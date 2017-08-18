From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v2 0/2] Covscan: Fix potential file descriptor
 leaks
Date: Fri, 18 Aug 2017 09:18:30 -0700
Message-ID: <20170818091830.395db3e0@xeon-e3>
References: <20170817170931.24224-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:37445 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751849AbdHRQSi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 12:18:38 -0400
Received: by mail-pg0-f52.google.com with SMTP id y129so67260591pgy.4
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 09:18:37 -0700 (PDT)
In-Reply-To: <20170817170931.24224-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Aug 2017 19:09:29 +0200
Phil Sutter <phil@nwl.cc> wrote:

> This series collects patches from v1 which deal with potential file
> descriptor leaks.
> 
> No changes to the actual patches, just splitting into smaller series.
> 
> Phil Sutter (2):
>   ss: Don't leak fd in tcp_show_netlink_file()
>   tc/em_ipset: Don't leak sockfd on error path
> 
>  misc/ss.c     | 32 ++++++++++++++++++++------------
>  tc/em_ipset.c |  1 +
>  2 files changed, 21 insertions(+), 12 deletions(-)
> 

Applied
