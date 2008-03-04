From: David Miller <davem@davemloft.net>
Subject: Re: [patch 06/11][NETNS][IPV6] ip6_fib - gc timer per namespace
Date: Mon, 03 Mar 2008 23:31:19 -0800 (PST)
Message-ID: <20080303.233119.63935286.davem@davemloft.net>
References: <20080302093720.649869114@mai.toulouse-stg.fr.ibm.com>
	<20080302094206.614993059@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49696
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752224AbYCDHbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 02:31:20 -0500
In-Reply-To: <20080302094206.614993059@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Sun, 02 Mar 2008 10:37:26 +0100

> Move the timer initialization at the network namespace creation
> and store the network namespace in the timer argument.
> 
> That enables multiple timers (one per network namespace) to do garbage
> collecting.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

Applied.
