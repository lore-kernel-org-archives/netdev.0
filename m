From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dm9000: control debug level of the driver
Date: Thu, 18 Aug 2011 22:09:02 -0700 (PDT)
Message-ID: <20110818.220902.1663745747317150778.davem@davemloft.net>
References: <1313426314-6422-1-git-send-email-vz@mleia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben-linux@fluff.org
To: vz@mleia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40864 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630Ab1HSFJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 01:09:20 -0400
In-Reply-To: <1313426314-6422-1-git-send-email-vz@mleia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladimir Zapolskiy <vz@mleia.com>
Date: Mon, 15 Aug 2011 19:38:34 +0300

> This change allows to get driver specific debug messages output
> setting a default value for db->debug_level. As far as the maximum
> level of verbosity is too high, it is demoted by default.
> 
> Signed-off-by: Vladimir Zapolskiy <vz@mleia.com>
> Cc: Ben Dooks <ben-linux@fluff.org>

I would much rather see this config option eliminated entirely.

The default can be set by the user at kernel boot or module
load time with command line settings.
