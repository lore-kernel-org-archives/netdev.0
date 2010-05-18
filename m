From: Jonas Bonn <jonas@southpole.se>
Subject: (unknown)
Date: Tue, 18 May 2010 07:39:23 +0200
Message-ID: <1274161166-18521-1-git-send-email-jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:35397 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756642Ab0ERF6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 01:58:32 -0400
Received: from assp.southpole.se (localhost [127.0.0.1])
	by mail.southpole.se (Postfix) with ESMTPSA id 44365480163
	for <netdev@vger.kernel.org>; Tue, 18 May 2010 07:39:26 +0200 (CEST)
Subject: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two patches for the ethoc driver and one to the Micrel PHY driver.

I'd like feedback on the patch 1/3 (write bus addresses to registers) as I'm 
not totally confident that this won't break for someone else.  The MAC registers
should definitely be getting bus/physical addresses and ->membase is thus
the wrong value to be using (it's virtual); however, since I presume that 
this driver was working for somebody else before (???), then I'd like to know
that whatever use case they have isn't broken by this -- what configuration
would have ->membase == ->mem_start anyway?  NO_MMU?

The other two patches are pretty trivial.

Thanks,
Jonas

