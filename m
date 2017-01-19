From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH iproute2 net-next V5] tc: flower: Refactor matching
 flags to be more user friendly
Date: Thu, 19 Jan 2017 15:48:17 +0100
Message-ID: <20170119154817.26240372@griffin>
References: <1484836073-47019-1-git-send-email-paulb@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>
To: Paul Blakey <paulb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46188 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752884AbdASOsm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 09:48:42 -0500
In-Reply-To: <1484836073-47019-1-git-send-email-paulb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Jan 2017 16:27:53 +0200, Paul Blakey wrote:
> Instead of "magic numbers" we can now specify each flag
> by name. Prefix of "no"  (e.g nofrag) unsets the flag,
> otherwise it wil be set.
> 
> Example:
>     # add a flower filter that will drop fragmented packets
>     tc filter add dev ens4f0 protocol ip parent ffff: \
>             flower \
>             src_mac e4:1d:2d:fd:8b:01 \
>             dst_mac e4:1d:2d:fd:8b:02 \
>             indev ens4f0 \
>             ip_flags frag \
>     action drop
> 
>     # add a flower filter that will drop non-fragmented packets
>     tc filter add dev ens4f0 protocol ip parent ffff: \
>             flower \
>             src_mac e4:1d:2d:fd:8b:01 \
>             dst_mac e4:1d:2d:fd:8b:02 \
>             indev ens4f0 \
>             ip_flags nofrag \
>     action drop
> 
> Fixes: 22a8f019891c ('tc: flower: support matching flags')
> Signed-off-by: Paul Blakey <paulb@mellanox.com>
> Reviewed-by: Roi Dayan <roid@mellanox.com>

Reviewed-by: Jiri Benc <jbenc@redhat.com>
