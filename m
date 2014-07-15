From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net-next 00/12] bonding: convert pr_* to netdev_*
Date: Tue, 15 Jul 2014 20:07:51 +0200
Message-ID: <20140715180751.GB14109@mikrodark.usersys.redhat.com>
References: <1405445769-15394-1-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:53171 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754748AbaGOSKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 14:10:49 -0400
Received: by mail-wi0-f169.google.com with SMTP id n3so4538940wiv.0
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 11:10:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1405445769-15394-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2014 at 07:35:57PM +0200, Veaceslav Falico wrote:
>Currently bonding uses pr_info/warn/etc. function to print something, while
>it's encouraged to use netdev_info/warn/etc. in net/.
>
>This patchset converts them where possible (i.e. where we have a working
>net_device). Also, convert pr_ratelimit* to net_() and remove the pr_fmt,
>to unify netdev_* and pr_* outputs.
>
>
>CC: Jay Vosburgh <j.vosburgh@gmail.com>
>CC: Andy Gospodarek <andy@greyhouse.net>
>Signed-off-by: Veaceslav Falico <vfalico@gmail.com>

Sorry, it's on top of

[net-next] bonding: permit enslaving interfaces without set_mac support
http://patchwork.ozlabs.org/patch/369965/

as there I've got a request to change them.

>
>---
> drivers/net/bonding/bond_3ad.c     | 185 ++++++++++++++--------------
> drivers/net/bonding/bond_alb.c     |  36 +++---
> drivers/net/bonding/bond_debugfs.c |   6 +-
> drivers/net/bonding/bond_main.c    | 344 +++++++++++++++++++++++++----------------------------
> drivers/net/bonding/bond_netlink.c |  11 +-
> drivers/net/bonding/bond_options.c | 218 ++++++++++++++++-----------------
> drivers/net/bonding/bond_procfs.c  |   4 +-
> 7 files changed, 373 insertions(+), 431 deletions(-)
