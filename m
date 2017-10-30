From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tun/tap: sanitize TUNSETSNDBUF input
Date: Mon, 30 Oct 2017 16:07:30 -0700
Message-ID: <1509404850.11887.63.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171030225011.184639-1-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:45143 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753131AbdJ3XHc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 19:07:32 -0400
Received: by mail-io0-f176.google.com with SMTP id i38so30960249iod.2
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 16:07:32 -0700 (PDT)
In-Reply-To: <20171030225011.184639-1-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-10-30 at 18:50 -0400, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
> 
> Syzkaller found several variants of the lockup below by setting negative
> values with the TUNSETSNDBUF ioctl.  This patch adds a sanity check
> to both the tun and tap versions of this ioctl.
> 

Reviewed-by: Eric Dumazet <edumazet@google.com>

Thanks !
