From: Bo Mackey <bomack08@gmail.com>
Subject: Re: Severe regression in bnx2 driver with bonding in post 2.6.30 kernels
Date: Thu, 17 May 2012 20:21:06 +0000 (UTC)
Message-ID: <loom.20120517T221318-666@post.gmane.org>
References: <4BB3463A.2000801@openobjects.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:38551 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754505Ab2EQUZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 16:25:08 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1SV7Fw-0007S4-4d
	for netdev@vger.kernel.org; Thu, 17 May 2012 22:25:04 +0200
Received: from sjck-dmz-wsa-2.cisco.com ([173.36.196.7])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 17 May 2012 22:25:04 +0200
Received: from bomack08 by sjck-dmz-wsa-2.cisco.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 17 May 2012 22:25:04 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Stuart Shelton <stuart <at> openobjects.com> writes:

> 
> 
> Hi all,
> 
> The Broadcom NetXtreme II driver appears to have a severe regression in 
> all kernels post 2.6.30 - I've observed problems with 2.6.31, 2.6.32. 
> and 2.6.33.
> 
> The hardware impacted is an IBM Bladecenter LS21 Blade, model 7971.  We 
> have a large number of these, and all are affected.
> 
> We use generic channel-bonding, with the following options in modprobe.conf:
> 


Hi Stuart, et. al.,

Has the above issue been fixed? If so, can you please share the root cause and
the diffs? Seeing a similar issue in version 2.0.8 of the bnx2 driver.

Thank you,
Bo
