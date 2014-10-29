From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] neigh: optimize neigh_parms_release()
Date: Wed, 29 Oct 2014 12:01:03 -0700
Message-ID: <1414609263.631.90.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414607371-4246-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:52132 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754748AbaJ2TBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 15:01:02 -0400
Received: by mail-pd0-f177.google.com with SMTP id v10so3466415pde.8
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 12:01:01 -0700 (PDT)
In-Reply-To: <1414607371-4246-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-29 at 19:29 +0100, Nicolas Dichtel wrote:
> In neigh_parms_release() we loop over all entries to find the entry given in
> argument and being able to remove it from the list. By using a double linked
> list, we can avoid this loop.

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
