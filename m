From: Jay Vosburgh <j.vosburgh@gmail.com>
Subject: Re: [PATCH] Bonding Remove debug_fs files when module init fails
Date: Wed, 09 Apr 2014 12:53:56 -0700
Message-ID: <16237.1397073236@famine>
References: <1397040779-8699-1-git-send-email-tmricht@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org
To: Thomas Richter <tmricht@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:57418 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964976AbaDITx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 15:53:59 -0400
Received: by mail-pd0-f172.google.com with SMTP id p10so2875016pdj.3
        for <netdev@vger.kernel.org>; Wed, 09 Apr 2014 12:53:59 -0700 (PDT)
In-reply-to: <1397040779-8699-1-git-send-email-tmricht@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Richter <tmricht@linux.vnet.ibm.com> wrote:

>Remove the bonding debug_fs entries when the
>module initialization fails. The debug_fs
>entries should be removed together with all other
>already allocated resources.
>
>Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>

Signed-off-by: Jay Vosburgh <j.vosburgh@gmail.com>

>---
> drivers/net/bonding/bond_main.c | 1 +
> 1 file changed, 1 insertion(+)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 95a6ca7..c11e7b7 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -4492,6 +4492,7 @@ static int __init bonding_init(void)
> out:
> 	return res;
> err:
>+	bond_destroy_debugfs();
> 	bond_netlink_fini();
> err_link:
> 	unregister_pernet_subsys(&bond_net_ops);
>-- 
