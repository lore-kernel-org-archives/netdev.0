From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFC/PATCH] ipg: add jumbo frame support kconfig option
Date: Wed, 27 Feb 2008 03:05:07 -0500
Message-ID: <47C519B3.7050200@garzik.org>
References: <Pine.LNX.4.64.0802262148270.12999@sbz-30.cs.Helsinki.FI> <20080226123247.2b63bbf0@extreme> <47C49BDD.50205@garzik.org> <Pine.LNX.4.64.0802270942070.19136@sbz-30.cs.Helsinki.FI> <Pine.LNX.4.64.0802270952050.19294@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, romieu@fr.zoreil.com,
	sorbica@icplus.com.tw, jesse@icplus.com.tw,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36063 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764197AbYB0IFU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 03:05:20 -0500
In-Reply-To: <Pine.LNX.4.64.0802270952050.19294@sbz-30.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pekka J Enberg wrote:
> On Wed, 27 Feb 2008, Pekka J Enberg wrote:
>> Ok, so a sysfs attribute would be sufficient, I suppose?
> 
> s/sysfs attribute/module parameter/

You could do it that way, but really, a non-jumbo default MTU should be 
sufficient.

The user must take proactive action to change the MTU to jumbo at that 
point...  that way its far more likely to get tested, while being 
non-default, too.

	Jeff



