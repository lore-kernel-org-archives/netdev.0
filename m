From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: sungem - ifconfig eth0 mtu 1300 -> oops
Date: Tue, 22 Jun 2004 11:03:34 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1087920212.22687.50.camel@gaston>
References: <20040621141144.119be627.davem@redhat.com>
	 <40D847E3.2080109@nortelnetworks.com>  <40D84A9B.8010503@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Chris Friesen <cfriesen@nortelnetworks.com>,
        "David S. Miller" <davem@redhat.com>,
        Herbert Xu <herbert@gondor.apana.org.au>, kernel@nn7.de,
        Linux Kernel list <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <40D84A9B.8010503@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-06-22 at 10:04, Jeff Garzik wrote:
> Chris Friesen wrote:
> > Just a quick question.  Does the sungem chip support jumbo frames?  I'd 
> > like to use MTU of 9000 to make large local transfers more efficient, 
> > but it didn't seem to work last time I checked.
> 
> 
> Are you 100% certain you configured the other side to support jumbo?
> 
> Jumbo frames are non-standard, and sometimes require configuring MTU on 
> the switch or remote network card (if directly connected).

Well, it's not enabled in the driver I think, or at least it wasn't last
time I looked. Dave told me the chip fifo's are too small to do anything
useful with jumbo frames.

Ben.
