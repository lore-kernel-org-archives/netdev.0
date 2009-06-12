From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver
 configuration.
Date: Thu, 11 Jun 2009 17:09:48 -0700 (PDT)
Message-ID: <20090611.170948.66762524.davem@davemloft.net>
References: <alpine.LFD.2.00.0906111159080.31536@xanadu.home>
	<1244739166.2785.52.camel@achroite>
	<ba4215e10906111045yf7288fbt4495d4dc96217d65@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, nico@cam.org, netdev@vger.kernel.org
To: mfuzzey@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55942
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751834AbZFLAJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 20:09:46 -0400
In-Reply-To: <ba4215e10906111045yf7288fbt4495d4dc96217d65@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Fuzzey <mfuzzey@gmail.com>
Date: Thu, 11 Jun 2009 19:45:07 +0200

> The problems with the quick hack approach are:
> 1) Different for each driver
> 2) Need to understand how each driver works to do it
> 3) Need to maintain the driver patch against evolving kernel

Hardware specific solutions for hardware specific problems.

You can instantiate a platform_device that the driver matches
and uses to acquire board-specific-juju such as link modes
which are non-functional.
