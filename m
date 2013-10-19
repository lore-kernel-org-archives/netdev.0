From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] ss: make socket statistic parseable
Date: Sat, 19 Oct 2013 14:56:16 -0700
Message-ID: <1382219776.3284.49.camel@edumazet-glaptop.roam.corp.google.com>
References: <1382205252-14988-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	Eric Dumazet <edumazet@google.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:49009 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930Ab3JSV4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 17:56:18 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so4989044pab.36
        for <netdev@vger.kernel.org>; Sat, 19 Oct 2013 14:56:18 -0700 (PDT)
In-Reply-To: <1382205252-14988-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-10-19 at 19:54 +0200, Hagen Paul Pfeifer wrote:
> Currently "ss -emoi" output is nearly perfect: key value(s) tuples are
> delimited by colon. Except three groups: socket options, congestion
> control algorithm and send data. Especially the first two groups prevent
> automated parsing: what if a future congestion control algorithm is
> named "faster" - is this a TCP flag or a congestion control algorithm?
> The current syntax allow no parsing.
> 
> This patch harmonize the syntax for the last three remaining groups.
> 
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
> ---

Seems fine to me, maybe we want to support json for better parsing
capabilities ?
