From: Chris Snook <csnook@redhat.com>
Subject: Re: atl1: use magic packet wake-on-lan only
Date: Mon, 10 Nov 2008 13:42:25 -0500
Message-ID: <49188091.3090709@redhat.com>
References: <20081109150530.3eb555f9@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, Jie.yang@atheros.com, netdev@vger.kernel.org
To: "J. K. Cliburn" <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:47727 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754122AbYKJSmf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Nov 2008 13:42:35 -0500
In-Reply-To: <20081109150530.3eb555f9@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

J. K. Cliburn wrote:
> atl1: use magic packet wake-on-lan only
> 
> Of the various WOL options provided in include/linux/ethtool.h, the
> L1 NIC supports only magic packet.  Remove all options except magic
> packet from the atl1 driver.

Technically, we could implement the rest via the programmable 
pattern-matching hardware, but that would be an immense amount of work.

-- Chris
