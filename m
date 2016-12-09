From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 iproute2/net-next 3/3] tc: flower: support matching
 on ICMP type and code
Date: Fri, 9 Dec 2016 12:48:10 -0800
Message-ID: <20161209124810.11f02084@xeon-e3>
References: <1481118843-10428-1-git-send-email-simon.horman@netronome.com>
        <1481118843-10428-4-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34885 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752200AbcLIUsM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 15:48:12 -0500
Received: by mail-pf0-f170.google.com with SMTP id i88so4955738pfk.2
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 12:48:12 -0800 (PST)
In-Reply-To: <1481118843-10428-4-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  7 Dec 2016 14:54:03 +0100
Simon Horman <simon.horman@netronome.com> wrote:

> Support matching on ICMP type and code.
> 
> Example usage:
> 
> tc qdisc add dev eth0 ingress
> 
> tc filter add dev eth0 protocol ip parent ffff: flower \
> 	indev eth0 ip_proto icmp type 8 code 0 action drop
> 
> tc filter add dev eth0 protocol ipv6 parent ffff: flower \
> 	indev eth0 ip_proto icmpv6 type 128 code 0 action drop
> 
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Applied to net-next
