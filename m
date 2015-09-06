From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] switchdev: fix return value of
 switchdev_port_fdb_dump in case of error
Date: Sat, 05 Sep 2015 22:02:40 -0700 (PDT)
Message-ID: <20150905.220240.2260863312773628211.davem@davemloft.net>
References: <1441281857-613-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	sridhar.samudrala@intel.com, sfeldma@gmail.com, jiri@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35003 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865AbbIFFCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Sep 2015 01:02:41 -0400
In-Reply-To: <1441281857-613-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  3 Sep 2015 14:04:17 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> switchdev_port_fdb_dump is used as .ndo_fdb_dump. Its return value is
> idx, so we cannot return errval.
> 
> Fixes: 45d4122ca7cd ("switchdev: add support for fdb add/del/dump via switchdev_port_obj ops.")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks.
