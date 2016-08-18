From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip route: restore_handler should check
 tb[RTA_PREFSRC] for local networks
Date: Thu, 18 Aug 2016 14:54:53 -0700
Message-ID: <20160818145453.5f1ca90b@xeon-e3>
References: <f805ffe5dad63ae04330df32bbe6cf532a6772b7.1470561150.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>, phil@nwl.cc
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:32780 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753983AbcHSCLQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 22:11:16 -0400
Received: by mail-pf0-f181.google.com with SMTP id y134so4163178pfg.0
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 19:10:43 -0700 (PDT)
In-Reply-To: <f805ffe5dad63ae04330df32bbe6cf532a6772b7.1470561150.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun,  7 Aug 2016 17:12:30 +0800
Xin Long <lucien.xin@gmail.com> wrote:

> Prior to this patch, If one route entry's RTA_PREFSRC and RTA_GATEWAY
> both were NULL, it was supposed to be restored ONLY as a local address.
> 
> But as it didn't check tb[RTA_PREFSRC] when restoring local networks,
> rtattr_cmp would return a success if it was NULL, this route entry would
> be restored again as a local network.
> 
> This patch is to add tb[RTA_PREFSRC] check when restoring local networks.
> 
> Fixes: 74af8dd9620e ("ip route: restore route entries in correct order")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied
