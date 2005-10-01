From: Hendrik Visage <hvjunk@gmail.com>
Subject: Re: Starfire (Adaptec) kernel 2.6.13+ panics on AMD64 NFS server
Date: Sat, 1 Oct 2005 21:21:25 +0200
Message-ID: <d93f04c70510011221jf36525fla68c95160c0f0d38@mail.gmail.com>
References: <d93f04c70509292036x269df799y7b51c5be9c3356d6@mail.gmail.com>
	 <20050929211649.69eaddee.akpm@osdl.org>
	 <d93f04c70509300901s3836b8afw4792d16c589b4fc4@mail.gmail.com>
	 <20050930104046.4685e975.akpm@osdl.org>
	 <d93f04c70509301310y4bde1189wbcaef40124af6766@mail.gmail.com>
	 <20050930223915.GA17562@gondor.apana.org.au>
Reply-To: Hendrik Visage <hvjunk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Andrew Morton <akpm@osdl.org>, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org, ionut@badula.org,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050930223915.GA17562@gondor.apana.org.au>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/1/05, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> You must never call skb_checksum_help unless the packet is meant to
> be checksummed by the hardware.  So starfire is the guilty party here.
>
> This patch makes it do the check and also check for errors from
> skb_checksum_help.
>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanx Herbert,
 at least on 2.6.14_rc2 the patch appears to work for my stress test :)

--
Hendrik Visage
