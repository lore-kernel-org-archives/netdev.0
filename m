From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next iproute2 PATCH 2/2 v2] ss: Add inet raw sockets
 information gathering via netlink diag interface
Date: Wed, 2 Nov 2016 15:24:49 -0600
Message-ID: <f3c8047a-d629-f7ea-1e57-f18c7dfef07f@cumulusnetworks.com>
References: <1478092496-7540-1-git-send-email-gorcunov@gmail.com>
 <1478092496-7540-3-git-send-email-gorcunov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, avagin@openvz.org
To: Cyrill Gorcunov <gorcunov@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35793 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756401AbcKBVYv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 17:24:51 -0400
Received: by mail-pf0-f175.google.com with SMTP id i88so18137126pfk.2
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 14:24:50 -0700 (PDT)
In-Reply-To: <1478092496-7540-3-git-send-email-gorcunov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/2/16 7:14 AM, Cyrill Gorcunov wrote:
> unix, tcp, udp[lite], packet, netlink sockets already support diag
> interface for their collection and killing. Implement support
> for raw sockets.
> 
> Signed-off-by: Cyrill Gorcunov <gorcunov@gmail.com>
> ---
>  include/linux/inet_diag.h | 15 +++++++++++++++
>  misc/ss.c                 | 20 ++++++++++++++++++--
>  2 files changed, 33 insertions(+), 2 deletions(-)

worked for me. 

Acked-by: David Ahern <dsa@cumulusnetworks.com>
