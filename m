From: Baruch Even <baruch@ev-en.org>
Subject: Re: many sockets, slow sendto
Date: Tue, 6 Mar 2007 20:20:39 +0200
Message-ID: <20070306182039.GJ25760@galon.ev-en.org>
References: <E1HObHK-0000WB-00@osiris.swi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Zaccomer Lajos <zacco@fw.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:62917
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965524AbXCFSUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 13:20:40 -0500
Content-Disposition: inline
In-Reply-To: <E1HObHK-0000WB-00@osiris.swi.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Zaccomer Lajos <zacco@fw.hu> [070306 17:39]:
> Hi,
> 
> 
> 
> I'm playing around with a simulation, in which many thousands of IP
> 
> addresses (on interface aliases) are used to send/receive TCP/UDP
> 
> packets. I noticed that the time of send/sendto increased linearly
> 
> with the number of file descriptors, and I found it rather strange.

To better understand the reason for this problem you should first use
oprofile to profile the kernel. This will give you the hot spots of the
kernel, where the kernel (or userspace) spends most of its time.

Baruch
