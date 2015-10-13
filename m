From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] bridge: try switchdev op first in
 __vlan_vid_add/del
Date: Mon, 12 Oct 2015 19:35:44 -0700 (PDT)
Message-ID: <20151012.193544.2032005819905127445.davem@davemloft.net>
References: <1444391651-13775-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43057 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752827AbbJMCTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 22:19:45 -0400
In-Reply-To: <1444391651-13775-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri,  9 Oct 2015 13:54:11 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Some drivers need to implement both switchdev vlan ops and
> vid_add/kill ndos. For that to work in bridge code, we need to try
> switchdev op first when adding/deleting vlan id.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>

Applied, thanks.
