From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3 net-2.6.26] Compilation fixes.
Date: Wed, 02 Apr 2008 13:56:09 -0700 (PDT)
Message-ID: <20080402.135609.145425148.davem@davemloft.net>
References: <1207130474.17626.2.camel@iris.sw.ru>
	<20080402.114229.131377251.davem@davemloft.net>
	<1207165579.7118.4.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	containers@lists.osdl.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48584
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755847AbYDBU4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 16:56:09 -0400
In-Reply-To: <1207165579.7118.4.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Wed, 02 Apr 2008 23:46:19 +0400

> On Wed, 2008-04-02 at 11:42 -0700, David Miller wrote:
> > From: "Denis V. Lunev" <den@openvz.org>
> > Date: Wed, 02 Apr 2008 14:01:14 +0400
> > 
> > > Dave, could you pls conside this addition. This should fix problem
> > > reported by the Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> recently.
> > 
> > Then this invalidates enourmous amounts of CONFIG_NET tests
> > we've put into the headers over the past few days. 
> > 
> > All of them were explicitly to avoid having to provide the
> > init_net symbol when CONFIG_NET is not set.
> 
> OK. do you suggest to insert another CONFIG_NET check into if_pppox
> header or separate fs/compat_ioctl.c into two files:
> - for net ioctls
> - for the rest?

It's probably better to go your route.  That is, unprotect
the init_net extern, and remove the CONFIG_NET's we added
which are no longer necessary.

Could you do such a patch set?  Thanks.
