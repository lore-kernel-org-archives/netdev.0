From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 09/11] net/mlx4_en: Add debugfs support
Date: Wed, 30 Jan 2013 20:23:07 -0500 (EST)
Message-ID: <20130130.202307.2012762623231158868.davem@davemloft.net>
References: <1359542067-10760-1-git-send-email-amirv@mellanox.com>
	<1359542067-10760-10-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shanim@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47434 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756737Ab3AaBXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 20:23:11 -0500
In-Reply-To: <1359542067-10760-10-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Wed, 30 Jan 2013 12:34:25 +0200

> Add debugfs support to the mlx4_en driver such that users have the ability to access
> kernel information which can be used by external tools e.g HW monitoring ones
> 
> The filesystem is set up in the following driver/interface hierarchy:
> <debugfs>

Sigh...

This is a chronic problem.

Every time some driver developer can't figure out a way, using existing
well structured interfaces, to expose some information or statistic,
they just throw their hands in the air and add some debugfs turd.

Don't do this.

Instead, use or extend existing, well structured and typed, interfaces
to export your information.

That way every driver can export similar information in a familiar way
rather than with yet-another-debugfs-hack.

I'm not applying this series, sorry.
