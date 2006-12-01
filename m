From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] zd1211rw: Support for multicast addresses
Date: Thu, 30 Nov 2006 17:50:36 -0800
Message-ID: <20061130175036.35f0ccf7@localhost.localdomain>
References: <20061201005807.C04067B409F@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	kune@deine-taler.de, benoit.papillault@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:56017 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1755620AbWLABvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 20:51:03 -0500
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <20061201005807.C04067B409F@zog.reactivated.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri,  1 Dec 2006 00:58:07 +0000 (GMT)
Daniel Drake <dsd@gentoo.org> wrote:

> From: Ulrich Kunitz <kune@deine-taler.de>
> 
> Support for multicast adresses is implemented by supporting the
> set_multicast_list() function of the network device. Address
> filtering is supported by a group hash table in the device.
> 
> This is based on earlier work by Benoit Papillaut. Fixes multicast packet
> reception and ipv6 connectivity:
> http://bugzilla.kernel.org/show_bug.cgi?id=7424
> http://bugzilla.kernel.org/show_bug.cgi?id=7425
> 
> Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
> Signed-off-by: Daniel Drake <dsd@gentoo.org>


Why all the trouble do it off work queue? Is someone calling
set_multicast_list with IRQ's disabled?
