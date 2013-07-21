From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] qlcnic: Enhance ethtool to display board temperature.
Date: Sun, 21 Jul 2013 16:54:40 +0100
Message-ID: <1374422080.2804.1.camel@deadeye.wl.decadent.org.uk>
References: <1374206237-27233-1-git-send-email-himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Himanshu Madhani <himanshu.madhani@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:64215 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755662Ab3GUPys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 11:54:48 -0400
In-Reply-To: <1374206237-27233-1-git-send-email-himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-07-18 at 23:57 -0400, Himanshu Madhani wrote:
> From: Himanshu Madhani <himanshu.madhani@qlogic.com>
> 
> We need to provide a mechanism for a user space application to query
> adapter temperature. This RFC patch is to request input on which of the
> following approach would be appropriate way to export this information.
[...]

You should create a separate hwmon device.  As examples, this is
currently done by igb, ixgbe, sfc or tg3.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
