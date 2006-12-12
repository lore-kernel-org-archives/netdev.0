From: Roland Dreier <rdreier@cisco.com>
Subject: Re: examples of setting ip address/netmask/etc.. on a device
Date: Tue, 12 Dec 2006 14:08:46 -0800
Message-ID: <adahcw0u5qp.fsf@cisco.com>
References: <A02AEA26-70F9-4B55-A88A-235B3FF4C9F9@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:22818 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932470AbWLLWIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 17:08:50 -0500
To: Kumar Gala <galak@kernel.crashing.org>
In-Reply-To: <A02AEA26-70F9-4B55-A88A-235B3FF4C9F9@kernel.crashing.org> (Kumar Gala's message of "Tue, 12 Dec 2006 15:01:53 -0600")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > I was wondering if there were any examples of net devices that expect
 > to be told the ip information for their connection (things doing
 > forms of offload).  If so can someone point me at a driver that does
 > this.

I don't know much about the HW details but drivers/infiniband/hw/amso1100
does something like that.  drivers/infiniband is somewhat misnamed
these days but amso1100 is a driver for RDMA over ethernet hardware.
