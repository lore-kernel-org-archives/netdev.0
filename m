From: jamal <hadi@cyberus.ca>
Subject: Re: [IPSEC] Add XFRMA_SA/XFRMA_POLICY for delete notification
Date: Fri, 27 May 2005 20:30:42 -0400
Message-ID: <1117240242.6251.4.camel@localhost.localdomain>
References: <20050527233741.GA9157@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050527233741.GA9157@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-28-05 at 09:37 +1000, Herbert Xu wrote:
> Hi Dave:
> 
> This is the patch that I reverted due to Jamal's objection to it.
> I still think it's the right way to go which is why I'm submitting
> it.  As it is, all the xfrm event notifications sent by the kernel
> except the ones for SA/policy deletion are symmetric in the sense
> that if they were sent straight back to the kernel in that same
> form they would be accepted and perform the same action that
> triggered the initial events.  As far as I know this is true for
> non-xfrm netlink notifications as well, including deletion events.
> 

I have no objection to this patch going forth. I think i have
sufficiently expressed my dislike - but we gotta make progress;->

cheers,
jamal
