From: David Miller <davem@davemloft.net>
Subject: Re: [patch net v2 00/10] mlxsw: IPv4 UC router fixes
Date: Wed, 17 Aug 2016 19:19:07 -0400 (EDT)
Message-ID: <20160817.191907.1488606585095181062.davem@davemloft.net>
References: <1471444777-3412-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	ilant@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33156 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752797AbcHQXTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 19:19:10 -0400
In-Reply-To: <1471444777-3412-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 17 Aug 2016 16:39:27 +0200

> Ido says:
> Patches 1-3 fix a long standing problem in the driver's init sequence,
> which manifests itself quite often when routing daemons try to configure
> an IP address on registered netdevs that don't yet have an associated
> vPort.
> 
> Patches 4-9 add missing packet traps for the router to work properly and
> also fix ordering issue following the recent changes to the driver's init
> sequence.
> 
> The last patch isn't related to the router, but fixes a general problem
> in which under certain conditions packets aren't trapped to CPU.
> 
> v1->v2:
> - Change order of patch 7
> - Add patch 6 following Ilan's comment
> - Add patchset name and cover letter

Series applied, thanks.
