From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net-next] bonding: permit enslaving interfaces without
 set_mac support
Date: Tue, 15 Jul 2014 13:59:19 +0200
Message-ID: <20140715115919.GA5225@mikrodark.usersys.redhat.com>
References: <1405423561-9114-1-git-send-email-vfalico@gmail.com>
 <53C5145E.5040908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Varka Bhadram <varkabhadram@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:52073 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758321AbaGOMCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 08:02:18 -0400
Received: by mail-wg0-f44.google.com with SMTP id m15so5361302wgh.3
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 05:02:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <53C5145E.5040908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2014 at 05:15:34PM +0530, Varka Bhadram wrote:
>On 07/15/2014 04:56 PM, Veaceslav Falico wrote:
...snip...
>>-			pr_warn("%s: Warning: The first slave device specified does not support setting the MAC address\n",
>>-				bond_dev->name);
>>-			if (BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP) {
>>+		pr_warn("%s: Warning: The slave device specified does not support setting the MAC address\n",
>>+			bond_dev->name);
>
>netdev_warn() instead of pr_warn()... We are having net_device object?

It's done in consistency with the whole function - there are pr_*
everywhere there, and netdev_x here and there would only mess things up.

I'll send a follow-up patch that transforms all pr_* into netdev_*.

Thank you!
