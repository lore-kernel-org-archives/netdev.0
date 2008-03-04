From: David Miller <davem@davemloft.net>
Subject: Re: [patch 09/11][NETNS][IPV6] fib6_rules - handle several network
 namespaces
Date: Mon, 03 Mar 2008 23:33:18 -0800 (PST)
Message-ID: <20080303.233318.224145652.davem@davemloft.net>
References: <20080302093720.649869114@mai.toulouse-stg.fr.ibm.com>
	<20080302094230.642282606@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57813
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750960AbYCDHdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 02:33:19 -0500
In-Reply-To: <20080302094230.642282606@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Sun, 02 Mar 2008 10:37:29 +0100

> The fib6_rules_ops is moved to the network namespace structure.
> All references are changed to have it relatively to it.
> 
> Each time a network namespace is created a new fib6_rules_ops is
> allocated, initialized and stored into the network namespace
> structure.
> 
> The common part of the fib rules is namespace aware, so it is
> quite easy to retrieve the network namespace from the rules and use
> it in the different callbacks.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

Applied.
