From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] crypto_free_tfm callers do not need to check for NULL
Date: Tue, 30 Aug 2005 16:49:41 -0400
Message-ID: <20050830204941.GA10817@fieldses.org>
References: <200508302245.55392.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@mail.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>,
	Benjamin Reed <breed@users.sourceforge.net>,
	Andy Adamson <andros@citi.umich.edu>, netdev@vger.kernel.org,
	lksctp developers <lksctp-developers@lists.sourceforge.net>,
	Andy Adamson <andros@umich.edu>, linux-net@vger.kernel.org,
	linux-crypto@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Jesper Juhl <jesper.juhl@gmail.com>
Content-Disposition: inline
In-Reply-To: <200508302245.55392.jesper.juhl@gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 30, 2005 at 10:45:54PM +0200, Jesper Juhl wrote:
> Since the patch to add a NULL short-circuit to crypto_free_tfm() went in, 
> there's no longer any need for callers of that function to check for NULL.
...
> Feedback, ACK, NACK, etc welcome. 

I've no problem with the auth_gss or nfsv4 bits.--b.
