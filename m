From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: sungem - ifconfig eth0 mtu 1300 -> oops
Date: Tue, 22 Jun 2004 10:53:23 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D847E3.2080109@nortelnetworks.com>
References: <20040621141144.119be627.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, kernel@nn7.de,
        linux-kernel@vger.kernel.org, benh@kernel.crashing.org,
        netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040621141144.119be627.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Mon, 21 Jun 2004 23:03:16 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
>  > On Mon, Jun 21, 2004 at 10:33:50PM +1000, Herbert Xu wrote:
>  > >
>  > > Does this patch fix your problems?
>  >
>  > Oops, I had a thinko about min vs. max.  I've also decided to make the
>  > bigger MTU useful by adjusting the arguments to skb_put() as well.
>  > Please try this one instead.
> 
> Applied, thanks Herbert.

Just a quick question.  Does the sungem chip support jumbo frames?  I'd like to 
use MTU of 9000 to make large local transfers more efficient, but it didn't seem 
to work last time I checked.

Thanks,

Chris
