From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2, 1/1] tcp: accommodate sequence number to a peer's
 shrunk receive window caused by precision loss in window scaling
Date: Fri, 17 Feb 2017 09:44:15 -0800
Message-ID: <1487353455.1311.86.camel@edumazet-glaptop3.roam.corp.google.com>
References: <BA334603-D37E-4C94-BB8B-19A830E0355C@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: "Cui, Cheng" <Cheng.Cui@netapp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34086 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934074AbdBQRpF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 12:45:05 -0500
Received: by mail-pf0-f195.google.com with SMTP id o64so4522156pfb.1
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 09:44:16 -0800 (PST)
In-Reply-To: <BA334603-D37E-4C94-BB8B-19A830E0355C@netapp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-02-17 at 17:04 +0000, Cui, Cheng wrote:
> Prevent sending out a left-shifted sequence number from a Linux sender in 
> response to a peer's shrunk receive-window caused by losing least significant
> bits in window-scaling.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Cheng Cui <Cheng.Cui@netapp.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
