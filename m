From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: phy: adjust fixed_phy_register()
 return value
Date: Tue, 07 Oct 2014 13:02:33 -0400 (EDT)
Message-ID: <20141007.130233.354860766225253280.davem@davemloft.net>
References: <20141006183830.D4E82100BC1@puck.mtv.corp.google.com>
	<20141007.000754.1011567266866832634.davem@davemloft.net>
	<CAGXr9JF8fx6YH3szY=nwxTJeJgopBCW9Kzhcs33q4oFG5GNOBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	thomas.petazzoni@free-electrons.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46447 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753459AbaJGRCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 13:02:35 -0400
In-Reply-To: <CAGXr9JF8fx6YH3szY=nwxTJeJgopBCW9Kzhcs33q4oFG5GNOBQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Tue, 7 Oct 2014 09:47:37 -0700

> I'm not sure if I understand your comment. The caller of
> fixed_phy_register() now gets the pointer to the phydev created by
> get_phy_device(). What other thread is aware of this pointer and how could
> they free it? Isn't the caller of fixed_phy_register() exclusively in
> charge of the created phydev?

If this is the case then my concerns are unfounded.

Thanks for clearing that up and I'll apply your patch, thanks!
