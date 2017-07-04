From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH] ipv4: Export rtm_ipv4_policy.
Date: Tue, 4 Jul 2017 16:21:42 -0700
Message-ID: <CAJieiUgrxhXgm4zP5rU3GS854s25sjAGn7FqdBviAz5O11ZpTw@mail.gmail.com>
References: <20170704.071815.1571286541262131188.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f175.google.com ([209.85.217.175]:35134 "EHLO
        mail-ua0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752169AbdGDXVn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 19:21:43 -0400
Received: by mail-ua0-f175.google.com with SMTP id j53so133733575uaa.2
        for <netdev@vger.kernel.org>; Tue, 04 Jul 2017 16:21:43 -0700 (PDT)
In-Reply-To: <20170704.071815.1571286541262131188.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 4, 2017 at 7:18 AM, David Miller <davem@davemloft.net> wrote:
>
> The MPLS code now needs it.
>
> Fixes: 397fc9e5cefe ("mpls: route get support")
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---

Sorry david. Just saw this. It was a cut-copy-paste error.
It should be the below. I can also submit a patch. Thanks.

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c

index 4b6ff85..9a28c3f 100644

--- a/net/mpls/af_mpls.c

+++ b/net/mpls/af_mpls.c

@@ -2130,7 +2130,7 @@ static int mpls_getroute(struct sk_buff *in_skb,
struct nlmsghdr *in_nlh,

        u8 n_labels;



        err = nlmsg_parse(in_nlh, sizeof(*rtm), tb, RTA_MAX,

-                         rtm_ipv4_policy, extack);

+                         rtm_mpls_policy, extack);

        if (err < 0)

                goto errout;
