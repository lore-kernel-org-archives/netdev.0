From: jamal <hadi@cyberus.ca>
Subject: Re: Fw: 2.6.12-rc4-mm[12] - ULOG problem
Date: Thu, 19 May 2005 09:46:50 -0400
Message-ID: <1116510411.6240.54.camel@localhost.localdomain>
References: <Xine.LNX.4.44.0505190915010.15522-100000@thoron.boston.redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Herbert Xu <herbert@gondor.apana.org.au>,
        netdev@oss.sgi.com, Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0505190915010.15522-100000@thoron.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-19-05 at 09:16 -0400, James Morris wrote:
> On Wed, 18 May 2005, Andrew Morton wrote:
> 
> > cn_init() uses NETLINK_NFLOG.  Peculiar.
> 
> I raised this some time ago, and it was never fixed by the author.
> 

Sharing as was done here is not proper; perhaps the suggestion from
Andrew is the way to go.

The other thing we could do is allocate a set of IDs for private use
(as in private IPs).
However, something like connector should only get one ID and it can do
its own multiplexing based on "units".

cheers,
jamal
