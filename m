From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [rds-devel] net-next pull request: RDS
Date: Mon, 13 Sep 2010 13:14:28 -0400
Message-ID: <20100913171428.GR21374@think>
References: <4C892C9C.4060304@oracle.com>
 <4C8C9422.2070306@Voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Grover <andy.grover@oracle.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, RDS Devel <rds-devel@oss.oracle.com>,
	Roland Dreier <rdreier@cisco.com>
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:29232 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771Ab0IMROp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Sep 2010 13:14:45 -0400
Content-Disposition: inline
In-Reply-To: <4C8C9422.2070306@Voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 12, 2010 at 10:49:38AM +0200, Or Gerlitz wrote:
> Hi Andy, 
> 
> Some clarifications/questions from whatever quick look one can have over 107 patches...
> 
> Zach Brown's "RDS/IB: print IB event strings as well as their number" - commit
> 1bde04a63d532c2540d6fdee0a661530a62b1686 in net-next-2.6 looks perfect to reside as a helper function in the core IB stack which can be in use by other rdma drivers (e.g ipoib, iser, srp, etc). 
> 
> Chris Mason's "rds: recycle FMRs through lockless lists added net/rds/xlist.h" - 6fa70da6081bbcf948801fd5ee0be4d222298a43 adds net/rds/xlist.h - isn't this something that better be placed under include/linux/. etc?

Yes, I plan on expanding xlist.h a little and trying to use it in a few
other places.  But since RDS is currently the only consumer it made sense
to me to keep it in rds until I had more code in line to take advantage
of it.

-chris
