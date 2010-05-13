From: Chris Wright <chrisw@redhat.com>
Subject: Re: [net-next-2.6 V6 PATCH 1/2] Add netlink support for virtual port
 management (was iovnl)
Date: Thu, 13 May 2010 13:46:14 -0700
Message-ID: <20100513204614.GB30483@x200.localdomain>
References: <20100513201714.25579.53530.stgit@savbu-pc100.cisco.com>
 <20100513201720.25579.51230.stgit@savbu-pc100.cisco.com>
 <4BEC63DB.2090306@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <scofeldm@cisco.com>, davem@davemloft.net,
	netdev@vger.kernel.org, chrisw@redhat.com, arnd@arndb.de
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41869 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751600Ab0EMUqW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 16:46:22 -0400
Content-Disposition: inline
In-Reply-To: <4BEC63DB.2090306@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Patrick McHardy (kaber@trash.net) wrote:
> > +	} else  {
> > +		err = rtnl_vf_port_fill_nest(skb, dev, -1);
> 
> What does -1 mean?

It means no VFs.  Could be made a macro/enum constant

thanks,
-chris
