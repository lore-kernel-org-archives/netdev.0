From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: [PATCH] Make netif_rx_ni preempt-safe
Date: Wed, 20 Oct 2004 22:14:31 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410202214.31791.vda@port.imtp.ilyichevsk.odessa.ua>
References: <1098230132.23628.28.camel@krustophenia.net> <200410201811.44419.vda@port.imtp.ilyichevsk.odessa.ua> <1098290858.1429.70.camel@krustophenia.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, Andrew Morton <akpm@osdl.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@gondor.apana.org.au, maxk@qualcomm.com,
        irda-users@lists.sourceforge.net,
        Linux Network Development <netdev@oss.sgi.com>,
        Alain Schroeder <alain@parkautomat.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Lee Revell <rlrevell@joe-job.com>
In-Reply-To: <1098290858.1429.70.camel@krustophenia.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 20 October 2004 19:47, Lee Revell wrote:
> On Wed, 2004-10-20 at 11:11, Denis Vlasenko wrote:
> > 0x57 == 87 bytes is too big for inline.
> 
> Ugh.  So the only fix is not to inline it?

Yes.

You can make it conditionally inline/non-inline
depending on SMP/preempt if you feel masochistic today :),
but last time I asked davem thought that it is over the top.

Deinline it.
--
vda
