From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] netvsc: make sure napi enabled before vmbus_open
Date: Sun, 30 Apr 2017 09:22:53 -0700
Message-ID: <20170430092253.47b8c718@xeon-e3>
References: <20170426235830.14801-1-sthemmin@microsoft.com>
        <20170428.160913.1378797538282359486.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:34065 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1423944AbdD3QWz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 12:22:55 -0400
Received: by mail-pg0-f41.google.com with SMTP id v1so36293980pgv.1
        for <netdev@vger.kernel.org>; Sun, 30 Apr 2017 09:22:55 -0700 (PDT)
In-Reply-To: <20170428.160913.1378797538282359486.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Apr 2017 16:09:13 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Wed, 26 Apr 2017 16:58:30 -0700
> 
> > This fixes a race where vmbus callback for new packet arriving
> > could occur before NAPI is initialized. Happens more on WS2008
> > which takes longer to setup channel.
> > 
> > Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>  
> 
> This doesn't apply cleanly to 'net'.

Patch was for net-next. Will resend in next group
