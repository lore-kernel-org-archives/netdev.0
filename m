From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] AF_VMCHANNEL address family for guest<->host communication.
Date: Tue, 16 Dec 2008 13:55:42 +1100
Message-ID: <E1LCQ62-0001oT-2b@gondolin.me.apana.org.au>
References: <4946E597.6070308@codemonkey.ws>
Cc: davem@davemloft.net, gleb@redhat.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, kvm@vger.kernel.org
To: anthony@codemonkey.ws (Anthony Liguori)
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4946E597.6070308@codemonkey.ws>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anthony Liguori <anthony@codemonkey.ws> wrote:
> 
> If we used TCP, we don't have a useful TCP/IP stack in QEMU, so we'd 
> have to inject that traffic into the host Linux instance, and then 
> receive the traffic in QEMU.  Besides being indirect, it has some nasty 
> security implications that I outlined in my response to Jeremy's last note.

When combined with namespaces I don't see why using the kernel TCP
stack would create any security problems that wouldn't otherwise
exist.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
