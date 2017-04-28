From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3] net: bridge: Fix improper taking over HW
 learned FDB
Date: Sat, 29 Apr 2017 00:33:32 +0300
Message-ID: <0f46c6a6-3d9a-f577-b851-d1d89c293ec9@cumulusnetworks.com>
References: <1493408347-44779-1-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, stephen@networkplumber.org,
        bridge@lists.linux-foundation.org,
        Ido Schimmel <idosch@mellanox.com>
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f169.google.com ([209.85.128.169]:33777 "EHLO
        mail-wr0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2992569AbdD1Vdf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 17:33:35 -0400
Received: by mail-wr0-f169.google.com with SMTP id w50so40027952wrc.0
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 14:33:34 -0700 (PDT)
In-Reply-To: <1493408347-44779-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/04/17 22:39, Arkadi Sharshevsky wrote:
> Commit 7e26bf45e4cb ("net: bridge: allow SW learn to take over HW fdb
> entries") added the ability to "take over an entry which was previously
> learned via HW when it shows up from a SW port".
> 
> However, if an entry was learned via HW and then a control packet
> (e.g., ARP request) was trapped to the CPU, the bridge driver will
> update the entry and remove the externally learned flag, although the
> entry is still present in HW. Instead, only clear the externally learned
> flag in case of roaming.
> 
> Fixes: 7e26bf45e4cb ("net: bridge: allow SW learn to take over HW fdb entries")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Arkadi Sharashevsky <arkadis@mellanox.com>
> Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> v1->v2
> - net-next rebase.
> 
> v2->v3
> - remove redundant line.
> ---
>  net/bridge/br_fdb.c | 8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
> 

Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
