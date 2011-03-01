From: Vasu Dev <vasu.dev@linux.intel.com>
Subject: Re: [Open-FCoE] [PATCH] fcoe: correct checking for bonding
Date: Tue, 01 Mar 2011 10:09:47 -0800
Message-ID: <1299002987.7692.206.camel@vi2.jf.intel.com>
References: <20110228133245.GB7096@psychotron.brq.redhat.com>
	 <8433.1298913321@death> <4D6BE155.7050109@gmail.com>
	 <20110301063710.GD2855@psychotron.redhat.com> <4D6D31BA.3000105@gmail.com>
	 <1299002494.7692.202.camel@vi2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-scsi@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	James.Bottomley@HansenPartnership.com, devel@open-fcoe.org
To: Joe Eykholt <joe.eykholt@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:21491 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754177Ab1CASL7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 13:11:59 -0500
In-Reply-To: <1299002494.7692.202.camel@vi2.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-03-01 at 10:01 -0800, Vasu Dev wrote:
> On Tue, 2011-03-01 at 09:49 -0800, Joe Eykholt wrote:
> > 
> > Otherwise I'd add some parens or I might code this as:
> > 
> >         if ((netdev->priv_flags & (IFF_BONDING | IFF_MASTER)) ==
> >             (IFF_BONDING | IFF_MASTER))
> 
> or also skip == in code as:-
> 
> if (netdev->priv_flags & (IFF_BONDING | IFF_MASTER)) 
> 
> Would least save few chars in source code.

Never mind, you wanted to check both bits set instead checking only one
of them, my mistake, anycase these are in different fields as another
most recent response mentioned.

	Vasu

