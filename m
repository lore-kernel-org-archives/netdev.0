From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: Teach the igmp code to handle multiple
 namespaces
Date: Mon, 14 Jul 2008 22:21:18 -0700 (PDT)
Message-ID: <20080714.222118.113063201.davem@davemloft.net>
References: <m1od54dwar.fsf@frodo.ebiederm.org>
	<m1zloocgd8.fsf@frodo.ebiederm.org>
	<1215845905.8316.4.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54050
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751753AbYGOFVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 01:21:18 -0400
In-Reply-To: <1215845905.8316.4.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Sat, 12 Jul 2008 10:58:25 +0400

> On Fri, 2008-07-11 at 13:31 -0700, Eric W. Biederman wrote:
> > It turns out that I actually need working multicast reception in my
> > test environment, not something that just the something that doesn't
> > crash when a multicast packet comes in.
> > 
> > So on top of my previous patch that kept the kernel from crashing
> > when multicast frames come it.  Actual support for receiving multicast
> > data in a network namespace.
> > 
> > Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Acked-by: Denis V. Lunev <den@openvz.org>

This patch does not apply.

Current net-next-2.6 does not have an &init_net check in
ip_check_mc() so we get rejects.

I could have done the simple fixup, but I'd rather you did
it and check if your patch is still correct after whatever
removed that check.

Thanks.
