From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] updated, ethernet-bridge: update skb->priority in case
	forwarded frame has VLAN-header
Date: 11 Mar 2005 13:34:37 -0500
Message-ID: <1110566077.1071.16.camel@jzny.localdomain>
References: <914610115.20050311172022@yuriev.ru>
	 <20050311093724.6c8b6a6d@dxpl.pdx.osdl.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "leo.yuriev.ru" <leo@yuriev.ru>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Patrick McHardy <kaber@trash.net>,
	Ben Greear <greearb@candelatech.com>, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050311093724.6c8b6a6d@dxpl.pdx.osdl.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Actually there is a case to be made for this to be part of the
bridge code. A VLAN is a single collision domain which is mappable to a
collission domain that is a bridge.
infact the old VLAN code written by Lennert (and somebody else) had
those two intermingled.

cheers,
jamal

On Fri, 2005-03-11 at 12:37, Stephen Hemminger wrote:
> On Fri, 11 Mar 2005 17:20:22 +0300
> Leo Yuriev <leo@yuriev.ru> wrote:
> 
> > Kernel 2.6 (2.6.11)
> > 
> > When ethernet-bridge forward a packet and such ethernet-frame has
> > VLAN-tag, bridge should update skb->prioriry for properly QoS
> > handling. This small patch does this.
> > 
> > Based upon discussion during last week I added pskb_may_pull()
> > checking and simple mapping from 802.1p/user_priority to skb->priority.
> > 
> > Patch-by: Leo Yuriev <leo@yuriev.ru>
> 
> Do this as an ebtables module please.
> 
