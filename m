From: David Miller <davem@davemloft.net>
Subject: Re: [patch 02/11][NETNS][IPV6] ip6_fib - make it per network
 namespace
Date: Mon, 03 Mar 2008 23:25:38 -0800 (PST)
Message-ID: <20080303.232538.202413151.davem@davemloft.net>
References: <20080302093720.649869114@mai.toulouse-stg.fr.ibm.com>
	<20080302094133.726696590@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60783
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757045AbYCDHZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 02:25:39 -0500
In-Reply-To: <20080302094133.726696590@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Sun, 02 Mar 2008 10:37:22 +0100

> The fib table for ipv6 are moved to the network namespace structure.
> All references to them are made relatively to the network namespace.
> 
> All external calls to the ip6_fib functions taking the network namespace 
> parameter are made using the init_net variable, so the ip6_fib engine is
> ready for the namespaces but the callers not yet.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

Applied.
