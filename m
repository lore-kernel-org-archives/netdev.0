From: David Miller <davem@davemloft.net>
Subject: Re: [NETNS] Oops in register_pernet_operations() with
 CONFIG_NET_NS=n
Date: Fri, 26 Oct 2007 04:55:03 -0700 (PDT)
Message-ID: <20071026.045503.62376243.davem@davemloft.net>
References: <m1bqan5cuk.fsf@ebiederm.dsl.xmission.com>
	<20071026.043155.75000997.davem@davemloft.net>
	<4721D283.4050909@bull.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org, dlunev@gmail.com,
	containers@lists.osdl.org, clg@fr.ibm.com, xemul@openvz.org
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40242
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751955AbXJZLzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 07:55:03 -0400
In-Reply-To: <4721D283.4050909@bull.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Thery <benjamin.thery@bull.net>
Date: Fri, 26 Oct 2007 13:41:55 +0200

> David Miller wrote:
> > From: ebiederm@xmission.com (Eric W. Biederman)
> > Date: Thu, 25 Oct 2007 11:21:55 -0600
> > 
> >>> By the way, I think that we can in the case of undefined CONFIG_NET_NS
> >>> reduce register to calling ->init method and unregister to calling
> >>> ->exit method.
> >>>
> >>> This is a correct thing at least for now and will be welcomed by the all
> >>> embedded/etc people.
> >> I'm not fundamentally opposed.  Earlier versions of my patchset
> >> did that and more.   However I think the pain is greater then the
> >> gain right now.  Especially since this concept seem to require
> >> having quality inspected into it.
> > 
> > I think the correct thing to do for now is to simply remove these
> > __net_* markers and their definitions.  There are so many tricky cases
> > that it is easier to just get rid of them.
> > 
> > Could someone send me a patch which does that?
> 
> The attached patch revert Pavel's orginal patch from 2.6.23-mm1. 
> It should work fine with net-2.6 too.

Thanks for doing this.

But this appears to be still discussed, so I'll give
Denis and others another day to work out the fix they
want to include.
