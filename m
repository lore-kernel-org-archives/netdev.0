From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] switchdev: add swdev ops
Date: Sun, 15 Mar 2015 20:00:29 -0400 (EDT)
Message-ID: <20150315.200029.2060004791473258099.davem@davemloft.net>
References: <1426400107-6072-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, roopa@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52017 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751780AbbCPAAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 20:00:31 -0400
In-Reply-To: <1426400107-6072-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Sat, 14 Mar 2015 23:15:02 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> Per discussions at netconf, move switchdev ndo ops to a new swdev_ops to
> keep ndo namespace clean and maintain switchdev-related ops into one place.
> 
> There are no functional changes here; just shuffling ops around for better
> organization.

As Simon Horman mentioned, this series is not bisectable.

Someone trying to track down a bug in the switch code will
find that all the switch offloading stops happening after
patch #2.

You have to arrange these changes such that full functionality and no
regressions occur at each and every step of the patch seres.

Thanks.
