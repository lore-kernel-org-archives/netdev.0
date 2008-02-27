From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [RFC/PATCH] ipg: add jumbo frame support kconfig option
Date: Wed, 27 Feb 2008 09:44:44 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0802270942070.19136@sbz-30.cs.Helsinki.FI>
References: <Pine.LNX.4.64.0802262148270.12999@sbz-30.cs.Helsinki.FI>
 <20080226123247.2b63bbf0@extreme> <47C49BDD.50205@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, romieu@fr.zoreil.com,
	sorbica@icplus.com.tw, jesse@icplus.com.tw,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43090 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254AbYB0Hoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 02:44:46 -0500
In-Reply-To: <47C49BDD.50205@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Stephen Hemminger wrote:
> > Please don't do this as a config option. Config options seem like a good
> > idea to developers but are difficult for distributions.  Either 
> > support jumbo frames by default or not at all.

On Tue, 26 Feb 2008, Jeff Garzik wrote:
> Agreed, but to be more specific... always compile in jumbo frame 
> support. You don't have to enable it at runtime by default, though.

Ok, so a sysfs attribute would be sufficient, I suppose? I don't have the 
hardware though, so I don't even know if the jumbo frame code actually 
works at this point hence the RFC. So I'll wait for someone to test this 
before sending a new patch. Thanks for the review!

			Pekka
