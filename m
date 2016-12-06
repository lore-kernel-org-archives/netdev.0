From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/3] net/flow_dissector: Enable matching on
 flags for TC filter consumers
Date: Tue, 6 Dec 2016 13:43:58 +0100
Message-ID: <20161206124358.GM1984@nanopsycho>
References: <1481027579-23195-1-git-send-email-ogerlitz@mellanox.com>
 <1481027579-23195-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>, Roi Dayan <roid@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Tom Herbert <tom@herbertland.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:32840 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752585AbcLFMow (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 07:44:52 -0500
Received: by mail-wm0-f65.google.com with SMTP id u144so21222596wmu.0
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 04:44:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1481027579-23195-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Dec 06, 2016 at 01:32:57PM CET, ogerlitz@mellanox.com wrote:
>This is a pre-step to allow TC classifiers that makes use of the
>flow-dissector (e.g Flower) to match on flow-dissector flags which
>are located in the control struct.
>
>Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>---
> include/net/flow_dissector.h | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
>index c4f3166..a679e6c 100644
>--- a/include/net/flow_dissector.h
>+++ b/include/net/flow_dissector.h
>@@ -154,8 +154,8 @@ struct flow_dissector {
> };
> 
> struct flow_keys {
>+#define FLOW_KEYS_HASH_START_FIELD control
> 	struct flow_dissector_key_control control;
>-#define FLOW_KEYS_HASH_START_FIELD basic

How is this hashing related to cls_flower dissections? What am I
missing?
