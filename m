From: Pekka Savola <pekkas@netcore.fi>
Subject: RE: Route cache performance under stress
Date: Tue, 10 Jun 2003 14:41:08 +0300 (EEST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0306101432530.21247-100000@netcore.fi>
References: <20030610061010.Y36963@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ralph+d@istop.com, CIT/Paul <xerox@foonet.net>,
	"'Simon Kirby'" <sim@netnation.com>,
	"'David S. Miller'" <davem@redhat.com>,
	"fw@deneb.enyo.de" <fw@deneb.enyo.de>,
	"netdev@oss.sgi.com" <netdev@oss.sgi.com>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Jamal Hadi <hadi@shell.cyberus.ca>
In-Reply-To: <20030610061010.Y36963@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org

On Tue, 10 Jun 2003, Jamal Hadi wrote:
> Typically, real world is less intense than the lab. Ex: noone sends
> 100Mbps at 64 byte packet size.

Some attackers do, and if your box dies because of that.. well, you don't 
like it and your managers certainly don't :-)

> Typical packet is around 500 bytes
> average. 

Not sure that's really the case.  I have the impression the traffic is 
basically something like:
 - close to 1500 bytes (data transfers)
 - between 40-100 bytes (TCP acks, simple UDP requests, etc.)
 - something in between

> If linux can handle that forwarding capacity, it should easily
> be doing close to Gige real world capacity.

Yes, but not the worst case capacity you really have to plan for :-(

> Have you seen how the big boys advertise? when tuning specs they talk
> about bits/sec. Juniper just announced a blade at supercom that can do
> firewalling at 500Mbps.

May be for some, but they *DO* give their pps figures also; many operators
do, in fact, *explicitly* check the pps figures especially when there are
some slower-path features in use (ACL's, IPv6, multicast, RPF, etc.):  
that's much more important than the optimal figures which are great for 
advertising material and press releases :-).

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings

