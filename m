From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] arch_fast_hash: avoid indirect function calls
 and implement hash in asm
Date: Thu, 04 Dec 2014 17:37:10 +0100
Message-ID: <1417711030.5386.35.camel@localhost>
References: <e77237174e1b8d743ef5171e05abde82bc54af37.1417696901.git.hannes@stressinduktion.org>
	 <20141204155610.GA22340@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <jay.vosburgh@canonical.com>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141204155610.GA22340@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Do, 2014-12-04 at 23:56 +0800, Herbert Xu wrote:
> On Thu, Dec 04, 2014 at 02:08:50PM +0100, Hannes Frederic Sowa wrote:
> > By default the arch_fast_hash hashing function pointers are initialized
> > to jhash(2). If during boot-up a CPU with SSE4.2 is detected they get
> > updated to the CRC32 ones. This dispatching scheme incurs a function
> > pointer lookup and indirect call for every hashing operation.
> 
> Just curious, is jhash actually faster than generic C CRC32 on
> common platforms?

Yes, jhash always beats crc32 in software on x86_64 and ia32.

Bye,
Hannes
