From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] switchdev: don't use anonymous union on
 switchdev attr/obj structs
Date: Wed, 13 May 2015 14:21:11 -0400 (EDT)
Message-ID: <20150513.142111.2017464915353018530.davem@davemloft.net>
References: <1431541011-53025-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, ogerlitz@mellanox.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753692AbbEMSVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 14:21:16 -0400
In-Reply-To: <1431541011-53025-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Wed, 13 May 2015 11:16:50 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> Older gcc versions (e.g.  gcc version 4.4.6) don't like anonymous unions
> which was causing build issues on the newly added switchdev attr/obj
> structs.  Fix this by using named union on structs.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Reported-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied, thanks.
