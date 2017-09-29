From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH] ip-route: Fix for listing routes with RTAX_LOCK
 attribute
Date: Fri, 29 Sep 2017 12:02:56 -0700
Message-ID: <20170929120256.79894617@xeon-e3>
References: <20170928173356.17892-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas Haller <thaller@redhat.com>,
        Hangbin Liu <liuhangbin@gmail.com>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:56238 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752280AbdI2TDE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 15:03:04 -0400
Received: by mail-pg0-f41.google.com with SMTP id b11so262265pgn.12
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 12:03:04 -0700 (PDT)
In-Reply-To: <20170928173356.17892-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Sep 2017 19:33:56 +0200
Phil Sutter <phil@nwl.cc> wrote:

> This fixes a corner-case for routes with a certain metric locked to
> zero:
> 
> | ip route add 192.168.7.0/24 dev eth0 window 0
> | ip route add 192.168.7.0/24 dev eth0 window lock 0
> 
> Since the kernel doesn't dump the attribute if it is zero, both routes
> added above would appear as if they were equal although they are not.
> 
> Fix this by taking mxlock value for the given metric into account before
> skipping it if it is not present.
> 
> Reported-by: Thomas Haller <thaller@redhat.com>
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Looks good, Applied. Thanks Phil
