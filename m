From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPCOMP6] Fix ICMP type check
Date: Thu, 22 Jul 2004 12:19:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040722121952.407cc9c2.davem@redhat.com>
References: <20040722113429.GA15083@gondor.apana.org.au>
	<Pine.LNX.4.58.0407221025010.7557@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com, xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Pine.LNX.4.58.0407221025010.7557@devserv.devel.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 22 Jul 2004 10:25:24 -0400 (EDT)
James Morris <jmorris@redhat.com> wrote:

> On Thu, 22 Jul 2004, Herbert Xu wrote:
> 
> > It looks like IPCOMP was missed when the same problem was fixed in
> > AH/ESP.
> 
> What about esp4/ah4/ipcomp?  They look wrong too.

Those are testing something else, and I believe their tests
are correct.  They are saying:

	if (type != X || code != Y)
		return;

in these cases Herbert is mentioning it is testing against multiple
possible settings of just "type".

Herbert, I'll apply your patch, thanks.
