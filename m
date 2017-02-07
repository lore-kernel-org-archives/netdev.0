From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gro_cells: move to net/core/gro_cells.c
Date: Tue, 07 Feb 2017 15:48:53 -0800
Message-ID: <1486511333.7793.74.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486510635.7793.72.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:33181 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752480AbdBGX5Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 18:57:25 -0500
Received: by mail-pg0-f44.google.com with SMTP id 204so42891373pge.0
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 15:57:25 -0800 (PST)
In-Reply-To: <1486510635.7793.72.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-02-07 at 15:37 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> We have many gro cells users, so lets move the code to avoid
> duplication.
> 
> This creates a CONFIG_GRO_CELLS option.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

This is targeting net-next tree, just in case the lack of 
[PATCH net-next] is confusing :/
