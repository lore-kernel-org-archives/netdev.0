From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/2] tipc: introduce bearer add for remoteip
Date: Thu, 1 Sep 2016 08:35:20 -0700
Message-ID: <20160901083520.5e1c7300@xeon-e3>
References: <1472546220-23259-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: Richard Alpe <richard.alpe@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35199 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754471AbcIAPfl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 11:35:41 -0400
Received: by mail-pf0-f170.google.com with SMTP id x72so32497759pfd.2
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 08:35:10 -0700 (PDT)
In-Reply-To: <1472546220-23259-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Aug 2016 10:36:59 +0200
Richard Alpe <richard.alpe@ericsson.com> wrote:

> Introduce the ability to add remote IP addresses to an existing UDP
> bearer. On the kernel side, adding a "remoteip" to an existing bearer
> puts the bearer in "replicast" mode where TIPC multicast messages are
> send out to each configured remoteip using unicast. This is required
> for TIPC UDP bearers to work in environments where IP multicast is
> disabled.
> 
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
> Reviewed-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
> Acked-by: Jon Maloy <jon.maloy@ericsson.com>
> ---

Applied to net-next
