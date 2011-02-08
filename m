From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: Oops in tcp_output.c, kernel 2.6.38-rc3
Date: Tue, 8 Feb 2011 14:07:24 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1102081401480.5424@JBRANDEB-DESK2.amr.corp.intel.com>
References: <20110204153254.5c37c6f2@katamari> <20110207.130234.112590109.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "cebbert@redhat.com" <cebbert@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ilpo.jarvinen@helsinki.fi" <ilpo.jarvinen@helsinki.fi>,
	bruce.w.allan@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:44544 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753293Ab1BHWHp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Feb 2011 17:07:45 -0500
In-Reply-To: <20110207.130234.112590109.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 7 Feb 2011, David Miller wrote:

> From: Chuck Ebbert <cebbert@redhat.com>
> Date: Fri, 4 Feb 2011 15:32:54 -0500
> 
> > Analysis is below. (From https://bugzilla.redhat.com/show_bug.cgi?id=674622)
> > 
> >  BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
> >  IP: [<ffffffff81407b16>] tcp_write_xmit+0x694/0x7af
> 
> I bet this is some kind of bug in the driver or similar, what device
> and also what kind of network config (netfilter, packet scheduler,
> interface, routes, etc.) is this?

glaring at the bug dump shows e1000e as the only network driver that i can 
see, hardware seems to be the ICH10 chipset.  Copied bruce in case he's 
seen or heard anything.

appears to be this system:
http://www.asus.com/Product.aspx?P_ID=qH6ZSEJ8EPY6HoNU&content=specifications

