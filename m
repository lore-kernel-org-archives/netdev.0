From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [REGRESSION][PATCH V4 1/3] bpf jit: Make the filter.c::__load_pointer helper non-static  for the jits
Date: Mon, 2 Apr 2012 10:18:02 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6ECE@saturn3.aculab.com>
References: <4F75CC63.10405@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	"Matt Evans" <matt@ozlabs.org>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: "Jan Seiffert" <kaffeemonster@googlemail.com>,
	<netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <4F75CC63.10405@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> The function is renamed to make it a little more clear what it does.
> It is not added to any .h because it is not for general 
> consumption, only for bpf internal use (and so by the jits).

I'd have thought it better to put in into a bfp_internal.h
(or similar) with a big warning there about the asm users.

Possibly even worth adding some other defs that the asm
files will need (if there are any).

	David
