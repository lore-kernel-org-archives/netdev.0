From: James Morris <jmorris@redhat.com>
Subject: Re: [XFRM] Probe selected algorithm only
Date: Fri, 21 Jan 2005 09:01:41 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0501210901001.6594-100000@thoron.boston.redhat.com>
References: <20050121101938.GA1133@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050121101938.GA1133@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 21 Jan 2005, Herbert Xu wrote:

> Hi Dave:
> 
> This patch removes an annoying problem in xfrm_user.  As it is every
> time an SA is added it probes every known algorithm in the universe.
> Now if they all existed it would be OK.  However, for the ones which
> don't actually exist this causes multiple /sbin/modprobe processes to
> be spawned which slows the system down when you're adding hundreds of
> SAs.
> 
> Since we know the type of algorithm required when we're adding a new
> SA, we can get away with only probing the selected algorithms.  This
> is what the following patch does for xfrm_user.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Looks good to me.

Signed-off-by: James Morris <jmorris@redhat.com>



- James
-- 
James Morris
<jmorris@redhat.com>
