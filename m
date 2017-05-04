From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH iproute] tc: Reflect HW offload status
Date: Thu, 4 May 2017 17:17:21 +0200
Message-ID: <20170504151720.GA19349@vergenet.net>
References: <1493903715-29664-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, Roi Dayan <roid@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36959 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932090AbdEDPR3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 11:17:29 -0400
Received: by mail-wm0-f53.google.com with SMTP id m123so19423737wma.0
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 08:17:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1493903715-29664-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 04, 2017 at 04:15:15PM +0300, Or Gerlitz wrote:
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

Reviewed-by: Simon Horman <simon.horman@netronome.com>
