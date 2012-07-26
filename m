From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: bonding: sync netpoll code with bridge
Date: Thu, 26 Jul 2012 11:17:01 +0300
Message-ID: <20120726081700.GN4403@mwanda>
References: <20120725134710.GA25625@elgon.mountain>
 <1343286905.12207.7.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:24466 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834Ab2GZIRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 04:17:06 -0400
Content-Disposition: inline
In-Reply-To: <1343286905.12207.7.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 26, 2012 at 03:15:05PM +0800, Cong Wang wrote:
> On Wed, 2012-07-25 at 16:47 +0300, Dan Carpenter wrote:
> > Hello Amerigo Wang,
> > 
> > The patch 8a8efa22f51b: "bonding: sync netpoll code with bridge" from 
> > Feb 17, 2011, leads to the following warning:
> > drivers/net/bonding/bond_main.c:1849 bond_enslave()
> > 	 error: scheduling with locks held: 'read_lock:&bond->lock'
> 
> Yeah, makes sense. Just wondering why I didn't catch it when I tested
> that patch. Anyway, could you try the following patch?
> 

The warnings were static checker warnings, not something I tested.

regards,
dan carpenter
