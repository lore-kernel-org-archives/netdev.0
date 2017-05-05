From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute] tc: Reflect HW offload status
Date: Fri, 5 May 2017 09:49:53 -0700
Message-ID: <20170505094953.67f321d6@xeon-e3>
References: <1493903715-29664-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roi Dayan <roid@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:36608 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750955AbdEEQuB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 12:50:01 -0400
Received: by mail-pg0-f53.google.com with SMTP id q4so5557844pga.3
        for <netdev@vger.kernel.org>; Fri, 05 May 2017 09:50:01 -0700 (PDT)
In-Reply-To: <1493903715-29664-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  4 May 2017 16:15:15 +0300
Or Gerlitz <ogerlitz@mellanox.com> wrote:

> Currently there is no way of querying whether a filter is
> offloaded to HW or not when using "both" policy (where none
> of skip_sw or skip_hw flags are set by user-space).
> 
> Add two new flags, "in hw" and "not in hw" such that user
> space can determine if a filter is actually offloaded to
> hw or not. The "in hw" UAPI semantics was chosen so it's
> similar to the "skip hw" flag logic.
> 
> If none of these two flags are set, this signals running
> over older kernel.
> 
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>

Applied thanks
