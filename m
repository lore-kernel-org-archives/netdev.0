From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance tests
Date: Tue, 17 Jun 2003 13:51:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030617205101.GD25773@netnation.com>
References: <20030617200721.GA25773@netnation.com> <1055881034.3199.43.camel@tux.rsn.bth.se> <20030617203703.GB25773@netnation.com> <20030617.133635.84366118.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gandalf@wlug.westbo.se, Robert.Olsson@data.slu.se, ralph+d@istop.com,
   hadi@shell.cyberus.ca, xerox@foonet.net, fw@deneb.enyo.de,
   netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030617.133635.84366118.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jun 17, 2003 at 01:36:35PM -0700, David S. Miller wrote:

> I have no idea why they do this, it's the stupidest thing
> you can possibly do by default.
> 
> If we thought it was a good idea to turn this on by default
> we would have done so in the kernel.
> 
> Does anyone have some cycles to spare to try and urge whoever is
> repsponsible for this in Debian to leave the kernel's default setting
> alone?

Sure, I can do this.  But why is this stupid?  It uses more CPU, but
stops IP spoofing by default.  Specific firewall rules would have to be
created otherwise.  And the overhead only really shows when the routing
table is large, right?

Simon-
