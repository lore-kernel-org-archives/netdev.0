From: "Itamar Heim" <iheim@redhat.com>
Subject: RE: [PATCH] AF_VMCHANNEL address family for guest<->host	communication.
Date: Mon, 15 Dec 2008 13:26:52 -0500 (EST)
Message-ID: <039a01c95ee3$07e7f900$17b7eb00$@com>
References: <20081214115054.4066.14557.stgit@dhcp-1-237.tlv.redhat.com>	<20081214.224436.55256593.davem@davemloft.net> <4946717F.2090809@codemonkey.ws> <494697D4.6080300@goop.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'David Miller'" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<kvm@vger.kernel.org>, <virtualization@lists.linux-foundation.org>
To: "'Jeremy Fitzhardinge'" <jeremy@goop.org>,
	"'Anthony Liguori'" <anthony@codemonkey.ws>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <494697D4.6080300@goop.org>
Content-Language: en-us
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: kvm-owner@vger.kernel.org [mailto:kvm-owner@vger.kernel.org] On
> Behalf Of Jeremy Fitzhardinge
 
> The trouble is that it presumes that the host and guest (or whoever the
> endpoints are) are on the same physical machine and will remain that
> way.  Given that live migration is a feature that people seem to like,
> then you'd end up needing to transport this protocol over a real network
> anyway - and at that point you may as well use proper TCP/IP.   The
> alternative is to say either "if you use this feature you can't migrate,
> and you can only resume on the same host", or "you can use this feature,
> and we'll work out a global namespace and proxy it over TCP for you".
> Neither seems very satisfactory.
[IH] when migrating a guest to another host, migration takes care of
closing/opening of the VMChannel on the target host. The VMChannel is
local to the hypervisor, not accessible via network. Migration is not an
issue requiring the VMChannel to use TCP/IP.
