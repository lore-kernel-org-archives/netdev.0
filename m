From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 06/30] solos: Handle attribute show/store in kernel more
 sanely
Date: Tue, 17 Mar 2009 15:44:11 -0700
Message-ID: <20090317154411.598b9f00@nehalam>
References: <1237310370.27681.314.camel@macbook.infradead.org>
	<1237325355.27681.335.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40084 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753168AbZCQWoV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2009 18:44:21 -0400
In-Reply-To: <1237325355.27681.335.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Mar 2009 21:29:15 +0000
David Woodhouse <dwmw2@infradead.org> wrote:

> There are still a _lot_ of attributes, but for at least the basic ones
> we want to be able to get/set them from the kernel. Especially the ones
> we want to inform the ATM core about (link state, speed).
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
> ---

Since these are generic, please use some form of netlink for this
instead of sysfs.

Bonding was the first mistake (trying to use sysfs for a transactional API).
Pls don't repeat the mistake.
