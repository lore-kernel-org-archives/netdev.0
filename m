From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v4 net-next 06/27] bonding: modify
 bond_get_slave_by_dev() to use neighbours
Date: Tue, 24 Sep 2013 15:19:43 -0400 (EDT)
Message-ID: <20130924.151943.1884204173373827600.davem@redhat.com>
References: <1380023227-9576-1-git-send-email-vfalico@redhat.com>
	<1380023227-9576-7-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, fubar@us.ibm.com,
	andy@greyhouse.net
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47963 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754523Ab3IXTUu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 15:20:50 -0400
In-Reply-To: <1380023227-9576-7-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Tue, 24 Sep 2013 13:46:46 +0200

> -	return NULL;
> +	return (struct slave *)netdev_lower_dev_get_private(bond->dev,
> +							    slave_dev);
>  }

void pointers never need to be cast, please remove this "struct slave *"
cast.
