From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 1/2] devlink: add hardware messages tracing
 facility
Date: Mon, 11 Jul 2016 13:45:16 -0700 (PDT)
Message-ID: <20160711.134516.2253721322702070372.davem@davemloft.net>
References: <1468243128-6669-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	ivecera@redhat.com, rostedt@goodmis.org, mingo@redhat.com,
	jolsa@kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60346 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753108AbcGKUpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 16:45:18 -0400
In-Reply-To: <1468243128-6669-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 11 Jul 2016 15:18:47 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Define a tracepoint and allow user to trace messages going to and from
> hardware associated with devlink instance.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Jiri, I don't think "having a devlink_ prefix" is a strong enough argument
for doing things specially here.

Just use the tracing facilities and export them the way everyone else
does, and the way that two people already have suggested.

Thanks.
