From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: primary and secondary ip addresses
Date: Fri, 17 Dec 2004 22:55:21 +0200
Message-ID: <200412172255.21316.hasso@estpak.ee>
References: <41912F7A.6000408@redhat.com> <200412172053.28016.hasso@estpak.ee> <Pine.LNX.4.61.0412172021190.18385@filer.marasystems.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Martin A. Brown" <mabrown@securepipe.com>,
	linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Henrik Nordstrom <hno@marasystems.com>
In-Reply-To: <Pine.LNX.4.61.0412172021190.18385@filer.marasystems.com>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Henrik Nordstrom wrote:
> On Fri, 17 Dec 2004, Hasso Tepper wrote:
> > All these tricks don't help if you are using dynamic routing.
>
> Are you seriously saying you are doing dynamic routing for your locally
> attached lans?
>
> source address assignment for routed traffic via gateways is
> automatically derived by the source address assignment for traffic
> addressed to the gateway itself.

So? Router learns via rip that default route should go via 10.0.0.1 and it 
has 10.0.0.2/24 and 10.0.0.3/24 addresses on eth0.

> So even with routing protocols etc you 
> can control the source address assignment simply by setting up routing to
> use the correct source address to speak to your gateways, the added
> routes will then inherit the intended source address.

No. It would be true in very trivial case only - ie. "use address I'm using 
for announcing these routes as gateway for these routes". All routing 
protocols can carry nexthop information. Moreover, addresses routing 
protocols use for transport don't have to have anything common with 
addresses used for routing. You can even carry IPv4 routing info with 
routing protocol using IPv6 for transport (ospfv3) or iso (is-is).

-- 
Hasso Tepper
Elion Enterprises Ltd.
WAN administrator
