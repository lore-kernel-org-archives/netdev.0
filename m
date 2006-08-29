From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC IPv6] Disabling IPv6 autoconf
Date: Tue, 29 Aug 2006 08:51:50 -0700
Message-ID: <20060829085150.03fc9bb3@localhost.localdomain>
References: <20060829082435.GA2676@suse.de>
	<20060829.183426.52410264.yoshfuji@linux-ipv6.org>
	<20060829104418.GI1201@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, jbeulich@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:17366 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965037AbWH2Pv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 11:51:59 -0400
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20060829104418.GI1201@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 29 Aug 2006 12:44:18 +0200
Olaf Kirch <okir@suse.de> wrote:

> On Tue, Aug 29, 2006 at 06:34:26PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> > > The attached tentative patch makes IPv6 autoconf depend on the
> > > availability of IFF_MULTICAST. This is admittedly a bit of a hack, but
> > > it makes sense, since DAD and router solicitation do rely on multicast.
> > 
> > I disagree.  The node MUST NOT assign live address on
> > that interface.
> 
> I'm not sure I understand. The Xen bridge devices get fe:ff:ff:ff:ff:ff
> as MAC address.  Which is a bit hackish, but that seems to be the way
> the Xen folks want to do it.

They should be using random_ether_addr() or putting some per instance
specific info into the address.

-- 
Stephen Hemminger <shemminger@osdl.org>
