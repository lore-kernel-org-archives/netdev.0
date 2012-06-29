From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] [TCP 1/3] tcp: Add MSG_NEW_PACKET flag to indicate
 preferable packet boundaries
Date: Fri, 29 Jun 2012 17:11:06 +0200
Message-ID: <1340982666.21162.3.camel@edumazet-glaptop>
References: <1340981690.25226.3.camel@gurkel.linbit>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: Andreas Gruenbacher <agruen@linbit.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340981690.25226.3.camel@gurkel.linbit>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-06-29 at 16:54 +0200, Andreas Gruenbacher wrote:
> The MSG_NEW_PACKET flag indicates to sendmsg / sendpage that the message or
> page should be put into a new packet even when there is still room left in the
> previous packet.
> 
> In the tcp protocol, messages which are not sent immediately are queued.  When
> more data is sent, it will be added to the last segment in that queue until
> that segment is "full" whenever possible; only then is a new segment added.
> Right now, there is no way to indicate when tcp should start a new segment.
> The new flag allows to control that.
> 
> Signed-off-by: Andreas Gruenbacher <agruen@linbit.com>
> ---

I don't understand how maintaining any message boundaries at sender can
prevent any middlebox or the receiver to coalesce frames to any
boundaries it prefers ?
