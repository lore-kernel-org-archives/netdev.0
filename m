From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [net-next] kernel bug at dev.c:4021
Date: Sat, 8 Nov 2008 01:39:07 +0300
Message-ID: <20081107223907.GA18677@x200.localdomain>
References: <20081107154407.43165cc4@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.183]:30441 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751279AbYKGWfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 17:35:48 -0500
Received: by ik-out-1112.google.com with SMTP id c29so1274845ika.5
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2008 14:35:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081107154407.43165cc4@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 07, 2008 at 03:44:07PM -0600, Jay Cliburn wrote:
> Pulled davem's net-next today (20081107, head
> 167c6274c30d17c41742096d1a12c32bd3b7e366) and was greeted with an
> unbootable system.

>  [<ffffffff812444ed>] register_netdev+0x3f/0x4d
>  [<ffffffff811e85a1>] loopback_net_init+0x4c/0x89
>  [<ffffffff8123f3d8>] register_pernet_operations+0x39/0xb0
>  [<ffffffff8123f47b>] register_pernet_device+0x2c/0x59
>  [<ffffffff81534678>] ? net_dev_init+0x0/0x18d
>  [<ffffffff81534703>] net_dev_init+0x8b/0x18d

Do git-revert ae33bc40c0d96d02f51a996482ea7e41c5152695 meanwhile.
