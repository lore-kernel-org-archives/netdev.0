From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 2/2] net: diag: allow socket bytecode filters
 to match socket marks
Date: Wed, 24 Aug 2016 09:14:16 -0600
Message-ID: <5ae46988-46cc-6c6d-d2c0-772dcb7e29ec@cumulusnetworks.com>
References: <1472021186-4106-1-git-send-email-lorenzo@google.com>
 <1472021186-4106-2-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, davem@davemloft.net, ek@google.com
To: Lorenzo Colitti <lorenzo@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35896 "EHLO
        mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756572AbcHXPOZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 11:14:25 -0400
Received: by mail-pa0-f42.google.com with SMTP id di2so7378142pad.3
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 08:14:19 -0700 (PDT)
In-Reply-To: <1472021186-4106-2-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/24/16 12:46 AM, Lorenzo Colitti wrote:
> This allows a privileged process to filter by socket mark when
> dumping sockets via INET_DIAG_BY_FAMILY. This is useful on
> systems that use mark-based routing such as Android.
> 
> The ability to filter socket marks requires CAP_NET_ADMIN, which
> is consistent with other privileged operations allowed by the
> SOCK_DIAG interface such as the ability to destroy sockets and
> the ability to inspect BPF filters attached to packet sockets.
> 
> Tested: https://android-review.googlesource.com/261350
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
> ---
>  include/uapi/linux/inet_diag.h |  6 ++++++
>  net/ipv4/inet_diag.c           | 36 +++++++++++++++++++++++++++++++++---
>  2 files changed, 39 insertions(+), 3 deletions(-)

Acked-by: David Ahern <dsa@cumulusnetworks.com>
