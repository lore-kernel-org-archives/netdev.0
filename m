From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] ppp: don't use 0 in pointer context
Date: Wed, 8 Feb 2006 14:45:08 -0800
Message-ID: <OF71FA79DA.C4F20DA5-ON8825710F.007B701A-8825710F.007CB97E@us.ibm.com>
References: <E1F6xei-0006hc-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: adobriyan@gmail.com, carlsonj@workingcode.com (James Carlson),
	linux-ppp@vger.kernel.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, viro@ftp.linux.org.uk
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <E1F6xei-0006hc-00@gondolin.me.apana.org.au>
To: Herbert Xu <herbert@gondor.apana.org.au>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev-owner@vger.kernel.org wrote on 02/08/2006 02:19:20 PM:

> James Carlson <carlsonj@workingcode.com> wrote:
> > Alexey Dobriyan writes:
> >> -     if (ap == 0)
> >> +     if (!ap)
> > 
> > And the solution is to treat it as a boolean instead?!  I'm not sure
> > which is more ugly.
> 
> Treating it as a boolean looks good to me.  It's better than the 
existing
> code because it shuts sparse up.

        Why would sparse complain about this? 0 is a well-defined
pointer value (the only value guaranteed to be by the language).
        From K&R ANSI C edition, section 5.4:

        "Pointers and integers are not interchangeable. Zero is the sole
exception: the constant zero may be assigned to a pointer, and a pointer
may be compared with the constant zero."

                                                        +-DLS

