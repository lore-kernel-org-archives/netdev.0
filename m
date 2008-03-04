From: David Miller <davem@davemloft.net>
Subject: Re: [patch 08/11][NETNS][IPV6] fib6 rule - dynamic allocation of
 the rules struct ops
Date: Mon, 03 Mar 2008 23:32:40 -0800 (PST)
Message-ID: <20080303.233240.117337956.davem@davemloft.net>
References: <20080302093720.649869114@mai.toulouse-stg.fr.ibm.com>
	<20080302094216.617181602@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49708
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752793AbYCDHcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 02:32:41 -0500
In-Reply-To: <20080302094216.617181602@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Sun, 02 Mar 2008 10:37:28 +0100

> The fib6_rules_ops structure is dynamically allocated, so that allows
> to make several instances of it per network namespace.
> 
> The global static fib6_rules_ops structure is renamed to 
> fib6_rules_ops_template in order to quickly memcopy it for the
> structure initialization.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

Applied.
