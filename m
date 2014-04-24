From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [patch net-next] vlan: Don't allow vlan devices to change
 network namespaces.
Date: Thu, 24 Apr 2014 07:47:34 +0200
Message-ID: <20140424054734.GA16057@unicorn.suse.cz>
References: <1398170586-6668-1-git-send-email-chenweilong@huawei.com>
 <1398176819.29946.49.camel@edumazet-glaptop2.roam.corp.google.com>
 <5357280C.1000404@huawei.com>
 <53576A6F.2020207@6wind.com>
 <53586207.7060407@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.dichtel@6wind.com, Eric Dumazet <eric.dumazet@gmail.com>,
	kaber@trash.net, davem@davemloft.net, netdev@vger.kernel.org
To: chenweilong <chenweilong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44953 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751200AbaDXFrh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2014 01:47:37 -0400
Content-Disposition: inline
In-Reply-To: <53586207.7060407@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 24, 2014 at 08:59:51AM +0800, chenweilong wrote:
> On 2014/4/23 15:23, Nicolas Dichtel wrote:
> > Le 23/04/2014 04:40, chenweilong a =E9crit :
> >> And, 2) is not safe, if someone forgets to move eth1, eth1.5 will =
not work, making
> >> things complex.
> > We have to fix this case, because it is a valid use case to have et=
h1.5 in net0
> > and eth1 in another ns.
> >=20
> eth1.5 can receive and send packets in net0, the problem is you can't=
 add a new eth1.5
> in old ns, report 'error: File exists'.

And this is correct, as far as I can tell. If it was possible, which of
the two interfaces would receive VLAN tagged packets with VID 5 coming
to eth1?

                                                         Michal Kubecek
