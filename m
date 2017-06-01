From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH iproute2] iplink: Update usage in help message
Date: Thu, 1 Jun 2017 13:55:38 +0300
Message-ID: <CAJ3xEMh9qgGF9LbyNriPafiz3cgdiV8wQ9_A9Zbb4tU3oQ9agg@mail.gmail.com>
References: <1496304042-8773-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>, Eli Cohen <eli@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33860 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751475AbdFAKzj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 06:55:39 -0400
Received: by mail-oi0-f68.google.com with SMTP id w10so6136214oif.1
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 03:55:39 -0700 (PDT)
In-Reply-To: <1496304042-8773-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 1, 2017 at 11:00 AM, Tariq Toukan <tariqt@mellanox.com> wrote:
> From: Eli Cohen <eli@mellanox.com>
>
> Add to usage message a description of how to configure Infiniband node
> and port GUIDs.
>
> Fixes: d91fb3f4c7e4 ('Add support for configuring Infiniband GUIDs')
> Signed-off-by: Eli Cohen <eli@mellanox.com>
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
> ---
>  ip/iplink.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/ip/iplink.c b/ip/iplink.c
> index da3f9a779351..ea112f71befc 100644
> --- a/ip/iplink.c
> +++ b/ip/iplink.c
> @@ -91,6 +91,8 @@ void iplink_usage(void)
>                 "                                  [ query_rss { on | off} ]\n"
>                 "                                  [ state { auto | enable | disable} ] ]\n"
>                 "                                  [ trust { on | off} ] ]\n"
> +               "                                  [ node_guid { eui64 } ]\n"
> +               "                                  [ port_guid { eui64 } ]\n"
>                 "                         [ xdp { off |\n"
>                 "                                 object FILE [ section NAME ] [ verbose ] |\n"
>                 "                                 pinned FILE } ]\n"


Eli,

I see now that your original patch touched the man page but the word
infiniband isn't mentioned:

@@ -1196,6 +1200,12 @@ sent by the VF.
 .BI trust " on|off"
 - trust the specified VF user. This enables that VF user can set a
specific feature
 which may impact security and/or performance. (e.g. VF multicast
promiscuous mode)
+.sp
+.BI node_guid " eui64"
+- configure node GUID for the VF.
+.sp
+.BI port_guid " eui64"
+- configure port GUID for the VF.


would be good if you enhance this patch to spell something like

configure node GUID for infiniband VFs.

configure port GUID for infiniband VFs.

Or.
