From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: deadlock in 2.6.18.2 related to bridging?
Date: Thu, 15 Feb 2007 00:37:30 +0100
Message-ID: <20070214233730.GA16438@electric-eye.fr.zoreil.com>
References: <45D26479.7030103@candelatech.com> <20070214131205.1ace04ba@freekitty> <45D37E70.9090304@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:47074 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964812AbXBNXhw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Feb 2007 18:37:52 -0500
Content-Disposition: inline
In-Reply-To: <45D37E70.9090304@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear <greearb@candelatech.com> :
[...]
> e1000 appears clean, at least, but there are a lot of other
> drivers that are calling that method (I didn't check to see
> if they might be holding rtnl when called.)

Not that lot: only r8169, sis190, s2io and cassini (through change_mtu).

Bad week.

-- 
Ueimor
