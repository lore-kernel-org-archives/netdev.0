From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v6 1/2] flow dissector: ICMP support
Date: Wed, 7 Dec 2016 14:05:11 +0100
Message-ID: <20161207130511.GF1987@nanopsycho>
References: <1481114908-24189-1-git-send-email-simon.horman@netronome.com>
 <1481114908-24189-2-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>, Tom Herbert <tom@herbertland.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36714 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932388AbcLGNUW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 08:20:22 -0500
Received: by mail-wm0-f67.google.com with SMTP id m203so27792687wma.3
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 05:20:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1481114908-24189-2-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 07, 2016 at 01:48:27PM CET, simon.horman@netronome.com wrote:
>Allow dissection of ICMP(V6) type and code. This should only occur
>if a packet is ICMP(V6) and the dissector has FLOW_DISSECTOR_KEY_ICMP set.
>
>There are currently no users of FLOW_DISSECTOR_KEY_ICMP.
>A follow-up patch will allow FLOW_DISSECTOR_KEY_ICMP to be used by
>the flower classifier.
>
>Signed-off-by: Simon Horman <simon.horman@netronome.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
