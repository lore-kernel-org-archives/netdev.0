From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] netns: struct net content re-work
Date: Tue, 11 Dec 2007 02:27:24 -0800 (PST)
Message-ID: <20071211.022724.142575368.davem@davemloft.net>
References: <20071210163645.GA24030@iris.sw.ru>
	<m1prxd28h3.fsf@ebiederm.dsl.xmission.com>
	<475E3D59.10804@sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, den@openvz.org, containers@lists.osdl.org,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: den@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60083
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751462AbXLKK1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 05:27:25 -0500
In-Reply-To: <475E3D59.10804@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@sw.ru>
Date: Tue, 11 Dec 2007 10:33:45 +0300

> Eric W. Biederman wrote:
> > The idea of separate structures make sense, and seems needed and useful.
> > 
> > "Denis V. Lunev" <den@openvz.org> writes:
> > 
> >> diff --git a/include/net/netns/unix.h b/include/net/netns/unix.h
> >> new file mode 100644
> >> index 0000000..27b4e7f
> >> --- /dev/null
> >> +++ b/include/net/netns/unix.h
> >                    ^^^^^^
> > Given that we are making this per protocol adding a separate directory
> > to hold them seems to be the wrong grouping.  Ideally we want everything
> > for the protocol all together in the same location so it is easy
> > to find.  Possibly with a user/kernel split.
> > 
> > So perhaps unix_net.h
> The idea was simple:
> - I can name 5 files right now
> - I want them to be shown to gather by ls
> - so, there are 2 ways, namely:
>   # include/net/netns/unix.h
>   # include/net/netns-unix.h

I have no real objection to the new directory.
