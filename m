From: David Miller <davem@davemloft.net>
Subject: Re: [NETNS] Oops in register_pernet_operations() with
 CONFIG_NET_NS=n
Date: Fri, 26 Oct 2007 04:31:55 -0700 (PDT)
Message-ID: <20071026.043155.75000997.davem@davemloft.net>
References: <m1y7dr5esy.fsf@ebiederm.dsl.xmission.com>
	<4720C9B9.80706@gmail.com>
	<m1bqan5cuk.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlunev@gmail.com, benjamin.thery@bull.net, xemul@openvz.org,
	netdev@vger.kernel.org, clg@fr.ibm.com, containers@lists.osdl.org,
	dlezcano@fr.ibm.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58753
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751375AbXJZLbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 07:31:53 -0400
In-Reply-To: <m1bqan5cuk.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 25 Oct 2007 11:21:55 -0600

> > By the way, I think that we can in the case of undefined CONFIG_NET_NS
> > reduce register to calling ->init method and unregister to calling
> > ->exit method.
> >
> > This is a correct thing at least for now and will be welcomed by the all
> > embedded/etc people.
> 
> I'm not fundamentally opposed.  Earlier versions of my patchset
> did that and more.   However I think the pain is greater then the
> gain right now.  Especially since this concept seem to require
> having quality inspected into it.

I think the correct thing to do for now is to simply remove these
__net_* markers and their definitions.  There are so many tricky cases
that it is easier to just get rid of them.

Could someone send me a patch which does that?
