From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Repeatable r8169 kernel oops testcase
Date: Sun, 30 Nov 2008 23:45:00 +0100
Message-ID: <20081130224500.GD8529@electric-eye.fr.zoreil.com>
References: <1228040955.3304.9.camel@localhost.localdomain> <20081130063835.43284112@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Cliburn <jcliburn@gmail.com>, netdev@vger.kernel.org
To: Dale Ogilvie <k1qeelx02@sneakemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:45862 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753457AbYK3WpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2008 17:45:21 -0500
Content-Disposition: inline
In-Reply-To: <20081130063835.43284112@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Cliburn <jcliburn@gmail.com> :
[...]
> Does booting with clocksource=hpet change anything?  What about the
> others in 
> /sys/devices/system/clocksource/clocksource0/available_clocksource

Once this is done, can your send your .config and tell if simply
issuing an 'ethtool -s eth0 autoneg off' then 'ethtool -s eth0 autoneg on' 
makes a difference ?

-- 
Ueimor
