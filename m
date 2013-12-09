From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: Fw: [Bug 66691] New: iproute2: macvlan: Wrong root device shown
 if in different netns
Date: Mon, 9 Dec 2013 09:02:00 +0100
Message-ID: <20131209080200.GC5355@unicorn.suse.cz>
References: <20131206120543.0afaafb5@nehalam.linuxnetplumber.net>
 <CAGXs5wXC+eTZD3sXD4zFtkpY8tcU14Kr6AiA9=kugHups_KCHA@mail.gmail.com>
 <CAGXs5wXr-7vgmT39__cJ0xo3D4fFOkfmd4_C-5+zPAKGeWZugA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Kevin Wilson <wkevils@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:41440 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760557Ab3LIICD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Dec 2013 03:02:03 -0500
Content-Disposition: inline
In-Reply-To: <CAGXs5wXr-7vgmT39__cJ0xo3D4fFOkfmd4_C-5+zPAKGeWZugA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 07, 2013 at 11:18:52AM +0200, Kevin Wilson wrote:
> Shouldn't the macvlan be network nsmespace local device, like the vlan
> and VXLAN device (which have NETIF_F_NETNS set)?
> When a nework device has the NETIF_F_NETNS flag set, it cannot be
> moved from one network namespace to another.

I don't think so. A setup where a macvlan is in a different namespace is
used quite often, e.g. to provide a network device to an LXC container.

                                                          Michal Kubecek
