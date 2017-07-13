From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net] mlxsw: spectrum_router: do not drop refcnt on fib
 rule
Date: Thu, 13 Jul 2017 14:39:10 -0600
Message-ID: <ca0fb684-34fd-0744-1d84-829c187f6d70@gmail.com>
References: <1499973097-14579-1-git-send-email-dsahern@gmail.com>
 <2b419d5a-8dc7-6066-4c26-699a881ce425@gmail.com>
 <20170713203358.GA8349@splinter>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, netdev@vger.kernel.org
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35390 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753201AbdGMUjR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 16:39:17 -0400
Received: by mail-pg0-f66.google.com with SMTP id d193so8113832pgc.2
        for <netdev@vger.kernel.org>; Thu, 13 Jul 2017 13:39:17 -0700 (PDT)
In-Reply-To: <20170713203358.GA8349@splinter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/13/17 2:33 PM, Ido Schimmel wrote:
> Remains where? It's not clear to me how you concluded mlxsw is at fault.
> My setup is running net-next with the refcount patches and I didn't
> observe this.

Create a VRF.

see latest patch. mlxsw releasing the refcnt on the rule was the victim;
eric's patch to fix a delete was setting the refcnt to 1 after mlxsw
bumped it.
