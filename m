From: Pekka Savola <pekkas@netcore.fi>
Subject: ARP and knowledge of IP addresses [Re: [2.4 PATCH] bugfix: ARP
 respond on all devices]
Date: Wed, 20 Aug 2003 08:31:31 +0300 (EEST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0308200828010.32417-100000@netcore.fi>
References: <20030819112912.359eaea6.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Daniel Gryniewicz <dang@fprintf.net>, <alan@lxorguk.ukuu.org.uk>,
	<richard@aspectgroup.co.uk>, <skraw@ithnet.com>, <willy@w.ods.org>,
	<carlosev@newipnet.com>, <lamont@scriptkiddie.org>,
	<davidsen@tmr.com>, <bloemsaa@xs4all.nl>,
	<marcelo@conectiva.com.br>, <netdev@oss.sgi.com>,
	<linux-net@vger.kernel.org>, <layes@loran.com>,
	<torvalds@osdl.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030819112912.359eaea6.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003, David S. Miller wrote:
[...]
> Consider the situation logically.  When you're replying to an
> ARP, _HOW_ do you know what IP addresses are assigned to _MY_
> outgoing interfaces and _HOW_ do you know what subnets _EXIST_
> on the LAN?
> 
> The answer to both is, you'd don't know these things _EVEN_ if
> you are a router/gateway.

Maybe I'm missing something but -- isn't it perfectly valid to assume the
node *ITSELF* knows about its interfaces, IP addresses, and its routes?
(Certainly, it can't know of what subnets exist on the LAN if those
haven't been configured on the node, e.g. in the form of an "interface
routes".)

ARP could look it up.

Sure, it would seem a bit like an OSI layering violation, but that's no 
news as OSI layering isn't strict anyway and has been shredded to pieces 
already in many other places.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings

