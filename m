From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.25-git2 fails build (nf_nat_proto_sctp.ko)
Date: Sat, 19 Apr 2008 17:52:59 -0700 (PDT)
Message-ID: <20080419.175259.204074091.davem@davemloft.net>
References: <200804191329.m3JDTS0m023459@clem.clem-digital.net>
	<480A278E.60507@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: clem@clem.clem-digital.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <480A278E.60507@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Sat, 19 Apr 2008 19:10:38 +0200

> Pete Clements wrote:
> > Root device is (3, 1)
> > Setup is 11288 bytes (padded to 11776 bytes).
> > System is 1162 kB
> > CRC 695701be
> > Kernel: arch/x86/boot/bzImage is ready  (#4)
> >   Building modules, stage 2.
> >   MODPOST 132 modules
> > ERROR: "crc32c_le" [net/ipv4/netfilter/nf_nat_proto_sctp.ko] undefined!
> 
> 
> Sorry about that. We need to select LIBCRC32C.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, t hanks Patrick.
