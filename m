From: jamal <hadi@cyberus.ca>
Subject: Re: [RTNETLINK] Provide real oif
Date: 02 Dec 2003 07:31:57 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1070368316.1031.30.camel@jzny.localdomain>
References: <20031202110224.GA25957@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20031202110224.GA25957@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Tue, 2003-12-02 at 06:02, Herbert Xu wrote:
> Hi Dave:
> 
> This patch adds a new attribute RTA_PREFOIF to the RTNETLINK interface
> so that we can send the real oif to user space.  Hmm, would RTA_REALOIF
> be a better name? It really should be called RTA_OIF but that's already
> taken.
> 
> Currently if there are two entries in the routing cache that only differ
> by the value of oif then they will appear identical to user space.  The
> only way to tell them apart would be to export the value of oif from
> the kernel.
> 

Can you provide a real example (output of route display in user space)
where this would be valuable?
whats wrong with the combo of RTA_OIF and RTA_SRC?

cheers,
jamal
