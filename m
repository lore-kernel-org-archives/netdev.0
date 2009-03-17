From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH 06/30] solos: Handle attribute show/store in kernel
 more sanely
Date: Tue, 17 Mar 2009 22:49:32 +0000
Message-ID: <1237330172.27829.14.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
	 <1237325355.27681.335.camel@macbook.infradead.org>
	 <20090317154411.598b9f00@nehalam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33470 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757524AbZCQWtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 18:49:40 -0400
In-Reply-To: <20090317154411.598b9f00@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-03-17 at 15:44 -0700, Stephen Hemminger wrote:
> Since these are generic, please use some form of netlink for this
> instead of sysfs.
> 
> Bonding was the first mistake (trying to use sysfs for a transactional
> API).
> Pls don't repeat the mistake.

It's not a transactional API.

The sysfs model actually fits the communication with the hardware almost
perfectly -- there are a bunch of named parameters, all of which can be
read and a few of which can be written to. A sysfs read or write
translates directly into a single exchange with the device's firmware.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

