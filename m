From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: initialize the routing table
Date: Sat, 09 Jul 2016 00:00:28 -0400 (EDT)
Message-ID: <20160709.000028.885177477710080482.davem@davemloft.net>
References: <20160707000354.18217-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58036 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750696AbcGIEBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 00:01:24 -0400
In-Reply-To: <20160707000354.18217-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Wed,  6 Jul 2016 20:03:54 -0400

> The routing table of every switch in a tree is currently initialized to
> all zeros. This is an issue since 0 is a valid port number.
> 
> Add a DSA_RTABLE_NONE=-1 constant to initialize the signed values of the
> routing table pointing to other switches.
> 
> This fixes the device mapping of the mv88e6xxx driver where the port
> pointing to the switch itself and to non-existent switches was wrongly
> configured to be 0. It is now set to the expected 0xf value.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
