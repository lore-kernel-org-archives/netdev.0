From: David Miller <davem@davemloft.net>
Subject: Re: BUG ? ipip unregister_netdevice_many()
Date: Fri, 08 Oct 2010 10:20:12 -0700 (PDT)
Message-ID: <20101008.102012.226761665.davem@davemloft.net>
References: <201010081353.28056.hans.schillstrom@ericsson.com>
	<201010081428.37639.hans.schillstrom@ericsson.com>
	<m1y6a81vms.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hans.schillstrom@ericsson.com, daniel.lezcano@free.fr,
	netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43350
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754201Ab0JHRTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 13:19:51 -0400
In-Reply-To: <m1y6a81vms.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 08 Oct 2010 09:45:15 -0700

> My hunch is that we have dst entry problems, as I know those hop network
> interfaces when we destroy network devices, but I have seen weird issues
> with the route cache as well.

While we're on this topic, can someone explain to me what the special
CONFIG_NET_NS code in net/ipv4/route.c:rt_do_flush() is trying to
accomplish?

If the issue is that there is an implicit ordering of releasing of
'dst' entries that must be maintained, we really ought to formalize
it (f.e. with dependency pointers or something like that).
