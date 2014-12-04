From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] arch_fast_hash: avoid indirect function calls
 and implement hash in asm
Date: Thu, 4 Dec 2014 23:56:11 +0800
Message-ID: <20141204155610.GA22340@gondor.apana.org.au>
References: <e77237174e1b8d743ef5171e05abde82bc54af37.1417696901.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jay Vosburgh <jay.vosburgh@canonical.com>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <e77237174e1b8d743ef5171e05abde82bc54af37.1417696901.git.hannes@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 04, 2014 at 02:08:50PM +0100, Hannes Frederic Sowa wrote:
> By default the arch_fast_hash hashing function pointers are initialized
> to jhash(2). If during boot-up a CPU with SSE4.2 is detected they get
> updated to the CRC32 ones. This dispatching scheme incurs a function
> pointer lookup and indirect call for every hashing operation.

Just curious, is jhash actually faster than generic C CRC32 on
common platforms?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
