From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH 2/2] [CRYPTO] users: Fix up scatterlist conversion errors
Date: Fri, 26 Oct 2007 11:44:38 -0400
Message-ID: <47220B66.5050002@hp.com>
References: <20071026145905.GA13850@gondor.apana.org.au> <E1IlQfN-0003cW-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763872AbXJZPpS@vger.kernel.org>
In-Reply-To: <E1IlQfN-0003cW-00@gondolin.me.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> [CRYPTO] users: Fix up scatterlist conversion errors
> 
> This patch fixes the errors made in the users of the crypto layer during
> the sg_init_table conversion.  It also adds a few conversions that were
> missing altogether.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> ---
> 
>  drivers/crypto/padlock-sha.c          |    4 +-
>  drivers/md/dm-crypt.c                 |    2 -
>  drivers/net/ppp_mppe.c                |   10 ++++-
>  drivers/scsi/iscsi_tcp.c              |    5 +-
>  fs/ecryptfs/crypto.c                  |    2 +
>  net/ipv4/esp4.c                       |    7 ++-
>  net/ipv6/esp6.c                       |    8 +++-
>  net/rxrpc/rxkad.c                     |   66 +++++++++++++++++-----------------
>  net/sctp/auth.c                       |    3 -
>  net/sctp/sm_make_chunk.c              |    6 +--
>  net/sunrpc/auth_gss/gss_krb5_crypto.c |   34 +++++++++++++----
>  net/sunrpc/auth_gss/gss_spkm3_seal.c  |    2 -
>  net/sunrpc/xdr.c                      |    2 +
>  13 files changed, 93 insertions(+), 58 deletions(-)
> 

Ack SCTP pieces.  I had those queued up, but you got to it before me ;)

Thanks
-vlad
