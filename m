From: "David S. Miller" <davem@redhat.com>
Subject: Re: [NET] Allow MD5 to be a module
Date: Thu, 29 Jul 2004 15:57:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040729155719.288882b5.davem@redhat.com>
References: <20040729114052.GA16001@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040729114052.GA16001@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 29 Jul 2004 21:40:52 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> I found that recent 2.6 kernels no longer allowed me to build MD5 as
> a module even though everything that used it were modules (including
> ipv6 and sctp).  It turns out that there were boolean options
> selecting MD5 in the Kconfig files.  Due to limitations in the current
> kconfig implementation, this forces MD5 to be a boolean as well.
> 
> The usual workaround in these cases is to move the selection up
> to the closest tristate.  This is what the following patch does.

Applied, thanks Herbert.
