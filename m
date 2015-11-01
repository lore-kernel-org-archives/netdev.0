From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH] net: dsa: use switchdev obj for VLAN add/del ops
Date: Sun, 1 Nov 2015 18:06:32 -0500
Message-ID: <20151101230632.GA17807@ketchup.lan>
References: <1446399235-30668-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20151101.155642.1302328563488956087.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, sfeldma@gmail.com, jiri@resnulli.us,
	f.fainelli@gmail.com, andrew@lunn.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:41773 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753087AbbKAXGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 18:06:36 -0500
Content-Disposition: inline
In-Reply-To: <20151101.155642.1302328563488956087.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Nov. Sunday 01 (44) 03:56 PM, David Miller wrote:
> From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> Date: Sun,  1 Nov 2015 12:33:55 -0500
> 
> > Simplify DSA by pushing the switchdev objects for VLAN add and delete
> > operations down to its drivers. Currently only mv88e6xxx is affected.
> > 
> > Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> > ---
> > v2: make _mv88e6xxx_port_vlan_del static as spotted by the kbuild robot.
> 
> According to your previous submission this is targetted at net-next,
> so that's where I applied it.

Right.

> But please do not make me play guessing games like this in the future.

Oops, wrong command, sorry about that...

Thanks,
-v
