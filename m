From: Florian Westphal <fw@strlen.de>
Subject: Re: Cannot move macvlan interface on top of bonding device
Date: Wed, 17 Sep 2014 21:06:26 +0200
Message-ID: <20140917190626.GA11354@breakpoint.cc>
References: <CA+HUmGi74nx0zELqXX63nJCNXshTC9AkWoRG5bo6AMHyr_3+fg@mail.gmail.com>
 <CAHA+R7O0LuvFujDnDjW-kcwG=9BGbaSBfO9GXhxD0ANLyeJLXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francesco Ruggeri <fruggeri@arista.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Weilong Chen <chenweilong@huawei.com>,
	Florian Westphal <fw@strlen.de>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:32909 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756013AbaIQTGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 15:06:34 -0400
Content-Disposition: inline
In-Reply-To: <CAHA+R7O0LuvFujDnDjW-kcwG=9BGbaSBfO9GXhxD0ANLyeJLXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <cwang@twopensource.com> wrote:
> On Wed, Sep 17, 2014 at 8:56 AM, Francesco Ruggeri <fruggeri@arista.com> wrote:
> > This used to work in older releases.
> > The problem seems to be that commit f939981492 sets NETIF_F_NETNS_LOCAL
> > on bonding interfaces, and commit 797f87f83 causes macvlan interfaces
> > to inherit its features from the lower device.
> >
> > Is there a reason why NETIF_F_NETNS_LOCAL should be inherited from the
> > lower device
> > by macvlan interfaces?
> 
> commit 797f87f83 looks wrong, it should not inherit NETIF_F_NETNS_LOCAL,
> so just clear this flag. Please submit a patch.

Under which conditions would NETIF_F_NETNS_LOCAL have to be inherited?
(i.e., why is it inheritable in the first place?)
