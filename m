From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RTNETLINK] Convert RTM_* to enum
Date: Tue, 14 Sep 2004 21:46:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040914214652.5ef63dfa.davem@davemloft.net>
References: <20040915020942.GA32721@gondor.apana.org.au>
	<Xine.LNX.4.44.0409142337130.28280-100000@thoron.boston.redhat.com>
	<20040915034748.GA952@gondor.apana.org.au>
	<20040914213837.75634b93.davem@davemloft.net>
	<20040915044555.GA1323@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040915044555.GA1323@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Sep 2004 14:45:55 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Tue, Sep 14, 2004 at 09:38:37PM -0700, David S. Miller wrote:
> > 
> > Right.  If we start using defines we have to keep them around.
> > I know it's bogus for people to ifdef this stuff, but we know
> > they do, and it's in bad taste to knowingly break stuff like that.
> 
> How about if we make it a rule that we only add new enum constants
> but not macros?

If you create some new enumeration from scratch, sure, but
for existing ones no.
