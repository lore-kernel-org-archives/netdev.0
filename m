From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: [PATCH] [REVISED] net/ipv4/multipath_wrandom.c: check kmalloc() return value.
Date: Wed, 14 Mar 2007 13:15:42 -0700
Message-ID: <20070314201542.GA4192@localhost.localdomain>
References: <Pine.LNX.4.64.0703121411170.13933@sbz-30.cs.Helsinki.FI> <20070312.135613.78710501.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: penberg@cs.helsinki.fi, amit2030@gmail.com,
	linux-kernel@vger.kernel.org, akpm@osdl.org,
	netdev@vger.kernel.org, shai@scalex86.org,
	pravin b shelar <pravin.shelar@calsoftinc.com>,
	"Benzi Galili (Benzi@ScaleMP.com)" <benzi@scalemp.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server99.tchmachines.com ([72.9.230.178]:35864 "EHLO
	server99.tchmachines.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422662AbXCNVLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2007 17:11:19 -0400
Content-Disposition: inline
In-Reply-To: <20070312.135613.78710501.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 12, 2007 at 01:56:13PM -0700, David Miller wrote:
> From: Pekka J Enberg <penberg@cs.helsinki.fi>
> Date: Mon, 12 Mar 2007 14:15:16 +0200 (EET)
> 
> > On 3/9/07, David Miller <davem@davemloft.net> wrote:
> > > The whole cahce-multipath subsystem has to have it's guts revamped for
> > > proper error handling.
> > 
> > (Untested patch follows.)
> 
> I'm not accepting untested patches, if people want to fix this
> code it cannot be done in a shoddy manner any more, it will
> need to be fixed and tested by people who really care about
> this code.

Hi Dave,
We do care for multipath cached option.  We do use it often with node
aware multipath.  We haven't experienced oopsen or crashes for our use cases
since the past year.  We will test Amit and Pekka's patch with fault injection.
We will also go through the core multipath-cached code and give a try at
cleaning it up.

> 
> We need real care for this code or I will remove it in 2.6.23

Can you please point us to any open bug reports on multipath cached?  We did 
a Call for testing on netdev sometime back but did not get any bug reports.  
http://marc.info/?l=linux-netdev&m=114827370231872&w=2

The kernel bugzilla shows zaroo boogs for multipath cached as well.

Thanks,
Kiran
