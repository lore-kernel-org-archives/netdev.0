From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 3/9] mlx4: Implement port type setting via
 devlink interface
Date: Tue, 23 Feb 2016 13:16:57 -0500 (EST)
Message-ID: <20160223.131657.1586772724014887499.davem@davemloft.net>
References: <1456165924-14399-4-git-send-email-jiri@resnulli.us>
	<56CC41C8.10802@stressinduktion.org>
	<20160223122109.GD2140@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, yishaih@mellanox.com, dledford@redhat.com,
	sean.hefty@intel.com, hal.rosenstock@gmail.com,
	eugenia@mellanox.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, hadarh@mellanox.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, jeffrey.t.kirsher@intel.com,
	brouer@redhat.com, ivecera@redhat.com, rami.rosen@intel.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39849 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279AbcBWSRB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 13:17:01 -0500
In-Reply-To: <20160223122109.GD2140@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 23 Feb 2016 13:21:10 +0100

> Sysfs is not the place to do this things.

+1

> It was already discussed here multiple times. There was and attempt
> to use configfs, which was also refused. Netlink is the only place
> to go. For multiple reasons, including well defined api and
> behaviour, notifications, etc.

+1
