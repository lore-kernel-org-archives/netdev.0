From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RTNETLINK] Convert RTM_* to enum
Date: Tue, 14 Sep 2004 21:38:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040914213837.75634b93.davem@davemloft.net>
References: <20040915020942.GA32721@gondor.apana.org.au>
	<Xine.LNX.4.44.0409142337130.28280-100000@thoron.boston.redhat.com>
	<20040915034748.GA952@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040915034748.GA952@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Sep 2004 13:47:48 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Tue, Sep 14, 2004 at 11:38:21PM -0400, James Morris wrote:
> > 
> > Having the enums as well as the defines is messy, I wonder if it's really
> > worth it.
> 
> I think the enum is definitely worth it for reducing the churn on
> the MAX value.
> 
> I personally don't see a point to the defines since the user-space
> appliations should not change behaviour based on compile-time
> settings.  However, others seem to have a different opinion on that.

Right.  If we start using defines we have to keep them around.
I know it's bogus for people to ifdef this stuff, but we know
they do, and it's in bad taste to knowingly break stuff like that.

Anyways, I'll apply your patch Herbert, thanks.
