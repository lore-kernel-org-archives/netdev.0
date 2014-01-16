From: Jiri Pirko <jiri@resnulli.us>
Subject: ipv6 addrconfg warn_on hit: WARN_ON(ifp->idev->valid_ll_addr_cnt <
 0);
Date: Thu, 16 Jan 2014 14:53:23 +0100
Message-ID: <20140116135323.GA7961@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:35902 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752743AbaAPNx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 08:53:27 -0500
Received: by mail-ea0-f174.google.com with SMTP id b10so1139669eae.5
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 05:53:26 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hannes.

WARN_ON(ifp->idev->valid_ll_addr_cnt < 0);

We did hit once this warning during the tests. The person who hit this
says that it was during the setup of many macvlan devices.

I examined the code but I'm not sure how this could happen. Looks like a
race condition between addrconf_dad_completed() and addrconf_ifdown(). 
Not sure how to easily resolve that though.

Would you please take a look?

Thanks!

Jiri
