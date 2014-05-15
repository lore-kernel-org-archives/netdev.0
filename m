From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net] bonding: fix out of range parameters for
 bond_intmax_tbl
Date: Thu, 15 May 2014 13:44:52 +0200
Message-ID: <20140515114452.GA28950@mikrodark.usersys.redhat.com>
References: <1400153723-8031-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:61083 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752744AbaEOLpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 07:45:14 -0400
Received: by mail-we0-f176.google.com with SMTP id q59so910957wes.7
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 04:45:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1400153723-8031-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 15, 2014 at 01:35:23PM +0200, Nikolay Aleksandrov wrote:
>I've missed to add a NULL entry to the bond_intmax_tbl when I introduced
>it with the conversion of arp_interval so add it now.
>
>CC: Jay Vosburgh <j.vosburgh@gmail.com>
>CC: Veaceslav Falico <vfalico@gmail.com>

Acked-by: Veaceslav Falico <vfalico@gmail.com>

>CC: Andy Gospodarek <andy@greyhouse.net>
>
>Fixes: 7bdb04ed0dbf ("bonding: convert arp_interval to use the new
>option API")
>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>---
> drivers/net/bonding/bond_options.c | 1 +
> 1 file changed, 1 insertion(+)
>
>diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
>index 724e30fa20b9..832070298446 100644
>--- a/drivers/net/bonding/bond_options.c
>+++ b/drivers/net/bonding/bond_options.c
>@@ -125,6 +125,7 @@ static const struct bond_opt_value bond_fail_over_mac_tbl[] = {
> static const struct bond_opt_value bond_intmax_tbl[] = {
> 	{ "off",     0,       BOND_VALFLAG_DEFAULT},
> 	{ "maxval",  INT_MAX, BOND_VALFLAG_MAX},
>+	{ NULL,      -1,      0}
> };
>
> static const struct bond_opt_value bond_lacp_rate_tbl[] = {
>-- 
>1.8.5.3
>
