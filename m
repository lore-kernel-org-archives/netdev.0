From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/2] bonding: remove the redundant judgements
 for bond_set_mac_address()
Date: Thu, 13 Feb 2014 15:29:49 +0100
Message-ID: <20140213142949.GA2829@minipsycho.orion>
References: <1392188330-17208-1-git-send-email-dingtianhong@huawei.com>
 <1392188330-17208-2-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	davem@davemloft.net, netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:49927 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001AbaBMO3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 09:29:54 -0500
Received: by mail-ea0-f173.google.com with SMTP id d10so5177027eaj.4
        for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 06:29:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1392188330-17208-2-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Feb 12, 2014 at 07:58:49AM CET, dingtianhong@huawei.com wrote:
>The dev_set_mac_address() will check the dev->netdev_ops->ndo_set_mac_address,
>so no need to check it in bond_set_mac_address().
>
>Cc: Jay Vosburgh <fubar@us.ibm.com>
>Cc: Veaceslav Falico <vfalico@redhat.com>
>Cc: Andy Gospodarek <andy@greyhouse.net>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Reviewed-by: Jiri Pirko <jiri@resnulli.us>
