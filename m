From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH/RFC iproute2/net-next 0/3] tc: flower: Support matching
 on ICMP
Date: Fri, 2 Dec 2016 18:10:20 +0100
Message-ID: <20161202171020.GD1883@nanopsycho.orion>
References: <1480672785-14570-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34659 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751872AbcLBRKX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 12:10:23 -0500
Received: by mail-wm0-f67.google.com with SMTP id g23so3694163wme.1
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 09:10:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1480672785-14570-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Dec 02, 2016 at 10:59:42AM CET, simon.horman@netronome.com wrote:
>Add support for matching on ICMP type and code to flower. This is modeled
>on existing support for matching on L4 ports.
>
>The second patch provided a minor cleanup which is in keeping with
>they style used in the last patch.
>
>This is marked as an RFC to match the same designation given to the
>corresponding kernel patches.

Looks nice, I only have those 2 enum nitpicks.

Thanks.

>
>Based on iproute2/net-next with the following applied:
>* [[PATCH iproute2/net-next v2] 0/4] tc: flower: SCTP and other port fixes
>
>Simon Horman (3):
>  tc: flower: update headers for TCA_FLOWER_KEY_ICMP*
>  tc: flower: introduce enum flower_endpoint
>  tc: flower: support matching on ICMP type and code
>
> include/linux/pkt_cls.h |  10 ++++
> man/man8/tc-flower.8    |  20 ++++++--
> tc/f_flower.c           | 118 ++++++++++++++++++++++++++++++++++++++++++------
> 3 files changed, 129 insertions(+), 19 deletions(-)
>
>-- 
>2.7.0.rc3.207.g0ac5344
>
