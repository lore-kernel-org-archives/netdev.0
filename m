From: David Miller <davem@davemloft.net>
Subject: Re: Possible leak of multicast source filter sctructure
Date: Sun, 13 Aug 2006 20:44:05 -0700 (PDT)
Message-ID: <20060813.204405.28205494.davem@davemloft.net>
References: <200608111004.k7BA4s6u009263@gateplz.comstar.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:47772
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751833AbWHNDnm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 23:43:42 -0400
To: michal.ruzicka@comstar.cz
In-Reply-To: <200608111004.k7BA4s6u009263@gateplz.comstar.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michal Ruzicka" <michal.ruzicka@comstar.cz>
Date: Fri, 11 Aug 2006 12:04:53 +0100

> You are absolutely right, I just failed to notice that -ENODEV return value
> from ip_mc_del_src()/ip_mc_leave_src() is ignored.
> Here comes the patch:
 ...
> >         Also, ip_mc_leave_group() has the same issue; looks
> > like it just needs the "if (in_dev)" removed before the call to
> > ip_mc_leave_src().
> 
> In fact it is a slightly different issue, there is no leak in this
> function. Rather the function completely fails to leave a multicast
> group joined on an interface that does not exist any more.
 ...
> Here comes a patch for that:

Both of these fixes look fine to me.  David?

(Meanwhile, Michal, can I get a Signed-off-by: line from you for these
 patches?  Thanks a lot.)
