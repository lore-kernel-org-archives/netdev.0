From: David Miller <davem@davemloft.net>
Subject: Re: [patch 05/11][NETNS][IPV6] ip6_fib - dynamically allocate
 gc-timer
Date: Mon, 03 Mar 2008 23:29:40 -0800 (PST)
Message-ID: <20080303.232940.08053649.davem@davemloft.net>
References: <20080302093720.649869114@mai.toulouse-stg.fr.ibm.com>
	<20080302094202.752774321@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49688
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752763AbYCDH3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 02:29:41 -0500
In-Reply-To: <20080302094202.752774321@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Sun, 02 Mar 2008 10:37:25 +0100

> The ip6_fib_timer gc timer is dynamically allocated and initialized in
> the ip6 fib init function. There are no more references to a
> static global variable. That will allow to make multiple instance
> of the garbage collecting timer and make them per namespace.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

Applied.
