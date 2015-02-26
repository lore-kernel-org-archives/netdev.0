From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx
 switches
Date: Thu, 26 Feb 2015 16:18:30 +0100
Message-ID: <20150226151830.GD8806@lunn.ch>
References: <20150224223039.GC1332@gospo.home.greyhouse.net>
 <CACna6rwBUqebNpf9XC21+LxZtR7xLn6wM-KWuxHR=E0KT6MSdQ@mail.gmail.com>
 <54ED017E.6000902@gmail.com>
 <20150225001534.GB15633@lunn.ch>
 <54ED19AB.7020003@gmail.com>
 <CACna6rzMcVd7SJ6NTBrrWtXe1ZTgxF5tgVb08eaPxxwTxWU1cg@mail.gmail.com>
 <20150225140356.GB17992@lunn.ch>
 <CACna6ryQzXQn4Gxn701pXCU6MrZje+w-5B0htM+-PukMbq7ZFQ@mail.gmail.com>
 <20150225141945.GC17992@lunn.ch>
 <CACna6ryUgu3wmQGmU1EomY-CDpBfh2BN8_K+V-XD_3mj4txLDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>, Jiri Pirko <jiri@resnulli.us>
To: Rafa?? Mi??ecki <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50276 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753725AbbBZPVg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2015 10:21:36 -0500
Content-Disposition: inline
In-Reply-To: <CACna6ryUgu3wmQGmU1EomY-CDpBfh2BN8_K+V-XD_3mj4txLDw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2015 at 03:58:40PM +0100, Rafa?? Mi??ecki wrote:
> On 25 February 2015 at 15:19, Andrew Lunn <andrew@lunn.ch> wrote:
> >> What do you mean by these recent patches? Has DSA recently received a
> >> support for bridging ports in the hardware? Like setting VLANs using
> >> some "bridge" comment (nl API) or something? Because I'm not aware of
> >> that.
> >
> > Yes. Scan over netdev list for the last week. e.g:
> >
> > http://comments.gmane.org/gmane.linux.network/350754
> 
> Hm, I can see it was actually merged to the net-next already:
> https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=bb66be1c549a0760500cfad404b3d79a136d0e44
> 
> But this dsa implementation is still totally unclear to me. So I can
> see we now have
> 1) port_join_bridge
> 2) port_leave_bridge
> 
> How does it allow me to bridge few ports with specifying PVID /
> (UN)TAG for some of them?

How about going back to the beginning. Look at the Starfigher 2 DSA
driver. Do you have similar registers? Can you map the Starfigher code
onto the b53 registers? If so, just write a new driver following the
Starfigher as a reference.

     Andrew
