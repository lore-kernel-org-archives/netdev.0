From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH] ss: Distinguish between IPv4 and IPv6 wildcard
 sockets
Date: Mon, 23 Oct 2017 14:41:42 +0200
Message-ID: <20171023144142.7496e791@shemminger-XPS-13-9360>
References: <20171016194958.669625db@xeon-e3>
        <20171018175813.5387-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Humberto Alves <hjalves@live.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:56932 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932176AbdJWMlv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 08:41:51 -0400
Received: by mail-wr0-f194.google.com with SMTP id r79so17229201wrb.13
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 05:41:51 -0700 (PDT)
In-Reply-To: <20171018175813.5387-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Oct 2017 19:58:13 +0200
Phil Sutter <phil@nwl.cc> wrote:

> Commit aba9c23a6e1cb ("ss: enclose IPv6 address in brackets") unified
> display of wildcard sockets in IPv4 and IPv6 to print the unspecified
> address as '*'. Users then complained that they can't distinguish
> between address families anymore, so change this again to what Stephen
> Hemminger suggested:
> 
> | *:80    << both IPV6 and IPV4
> | [::]:80 << IPV6_ONLY
> | 0.0.0.0:80  << IPV4_ONLY
> 
> Note that on older kernels which don't support INET_DIAG_SKV6ONLY
> attribute, pure IPv6 sockets will still show as '*'.
> 
> Cc: Humberto Alves <hjalves@live.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied both.
