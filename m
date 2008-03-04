From: David Miller <davem@davemloft.net>
Subject: Re: [patch 07/11][NETNS][IPV6] ip6_fib - clean node use namespace
Date: Mon, 03 Mar 2008 23:32:06 -0800 (PST)
Message-ID: <20080303.233206.18218773.davem@davemloft.net>
References: <20080302093720.649869114@mai.toulouse-stg.fr.ibm.com>
	<20080302094210.742423281@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49702
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752732AbYCDHcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 02:32:07 -0500
In-Reply-To: <20080302094210.742423281@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Sun, 02 Mar 2008 10:37:27 +0100

> The fib6_clean_node function should have the network namespace
> it is working on. The fib6_cleaner_t structure is extended with the
> network namespace field to be passed to the fib6_clean_node function.
> 
> The different functions calling the fib6_clean_node function are extended
> with the netns parameter when needed to propagate the netns pointer.
> 
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Applied.
