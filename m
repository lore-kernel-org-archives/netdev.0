From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v4 0/4] Covscan: Fix potential NULL pointer
 dereferences
Date: Thu, 24 Aug 2017 14:51:33 -0700
Message-ID: <20170824145133.2b5d9730@xeon-e3>
References: <20170824094634.4093-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:33606 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753335AbdHXVvm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 17:51:42 -0400
Received: by mail-pg0-f52.google.com with SMTP id t3so4144287pgt.0
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 14:51:42 -0700 (PDT)
In-Reply-To: <20170824094634.4093-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Aug 2017 11:46:30 +0200
Phil Sutter <phil@nwl.cc> wrote:

> This series collects patches from v1 which eliminate possible cases of
> NULL pointer dereferences.
> 
> Changes since v3:
> - Dropped upstream rejected patch 2.
> 
> Phil Sutter (4):
>   ifstat, nstat: Check fdopen() return value
>   tc/q_netem: Don't dereference possibly NULL pointer
>   tc/tc_filter: Make sure filter name is not empty
>   tipc/bearer: Prevent NULL pointer dereference
> 
>  misc/ifstat.c  | 16 +++++++++++-----
>  misc/nstat.c   | 16 +++++++++++-----
>  tc/q_netem.c   |  3 ++-
>  tc/tc_filter.c |  3 +++
>  tipc/bearer.c  |  2 +-
>  5 files changed, 28 insertions(+), 12 deletions(-)
> 

Applied. Thanks
