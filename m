From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v2 0/3] Covscan: Fix for missing error checking
Date: Mon, 21 Aug 2017 17:29:02 -0700
Message-ID: <20170821172902.14687270@xeon-e3>
References: <20170821163652.23752-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:32816 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754413AbdHVA3E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 20:29:04 -0400
Received: by mail-pg0-f42.google.com with SMTP id t3so80500257pgt.0
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 17:29:04 -0700 (PDT)
In-Reply-To: <20170821163652.23752-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Aug 2017 18:36:49 +0200
Phil Sutter <phil@nwl.cc> wrote:

> This series collects patches from v1 dealing with spots where error
> checking is necessary or recommended.
> 
> Minor changes to patches 1 and 2, patch 3 remains unchanged.
> 
> Phil Sutter (3):
>   iproute: Check mark value input
>   iplink_vrf: Complain if main table is not found
>   devlink: Check return code of strslashrsplit()
> 
>  devlink/devlink.c | 16 ++++++++++++----
>  ip/iplink_vrf.c   |  4 +++-
>  ip/iproute.c      |  6 ++++--
>  3 files changed, 19 insertions(+), 7 deletions(-)
> 

These 3 look fine. Applied
