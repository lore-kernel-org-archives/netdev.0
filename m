From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: next tree for October 27:  znet build failure
Date: Tue, 10 Nov 2009 09:19:45 -0800
Message-ID: <20091110091945.c373e41e.randy.dunlap@oracle.com>
References: <20091027190850.9694fb39.sfr@canb.auug.org.au>
	<4AE6BEC7.2030703@in.ibm.com>
	<20091028013721.049c0146.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Sachin Sant <sachinp@in.ibm.com>, linux-next@vger.kernel.org,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Greg KH <greg@kroah.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:25968 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260AbZKJRUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 12:20:16 -0500
In-Reply-To: <20091028013721.049c0146.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Oct 2009 01:37:21 +1100 Stephen Rothwell wrote:

> Just adding John and Greg to the cc list as this is caused by patches in
> the staging tree.

ping ping.  still a problem.


> On Tue, 27 Oct 2009 15:05:03 +0530 Sachin Sant <sachinp@in.ibm.com> wrote:
> >
> > Fails to build on x86_32 with lots of errors related to znet
> > 
> > drivers/net/znet.c:107:29: error: wireless/i82593.h: No such file or directory
> > drivers/net/znet.c:133: error: field 'i593_init' has incomplete type
> > drivers/net/znet.c: In function 'znet_set_multicast_list':
> > drivers/net/znet.c:235: error: invalid application of 'sizeof' to incomplete type 'struct i82593_conf_block'
> > drivers/net/znet.c:247: error: dereferencing pointer to incomplete type
> > .....
> > 
> > Commit 879e9304... moved wireless/i82593.h to drivers/staging/wavelan/i82593.h
> > 
> > Thanks
> > -Sachin


---
~Randy
