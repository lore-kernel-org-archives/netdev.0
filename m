From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [Fwd: kernel 2.4.21]
Date: Mon, 28 Jul 2003 11:07:37 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030728150737.GB1399@gtf.org>
References: <1058634345.22000.2.camel@dhcp22.swansea.linux.org.uk> <20030719191723.0821227f.davem@redhat.com> <3F1E53F7.5000803@unixtech.be> <20030723023528.76b0f69c.davem@redhat.com> <3F1E58EE.5010109@unixtech.be> <20030723024648.2e4b6a62.davem@redhat.com> <3F1E7435.4060308@unixtech.be> <20030727163422.28e44736.davem@redhat.com> <3F24D31F.5050904@unixtech.be> <20030728073240.03ff1c2e.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cedric Gavage <cedric.gavage@unixtech.be>, alan@lxorguk.ukuu.org.uk,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030728073240.03ff1c2e.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jul 28, 2003 at 07:32:40AM -0700, David S. Miller wrote:
> On Mon, 28 Jul 2003 09:39:11 +0200
> Cedric Gavage <cedric.gavage@unixtech.be> wrote:
> 
> > David S. Miller wrote:
> > > On Wed, 23 Jul 2003 13:40:37 +0200
> > > Cedric Gavage <cedric.gavage@unixtech.be> wrote:
> > >
> > >>Ok, now it's e100 driver, I will wait some hours to see if we have again 
> > >>problems, thanks for your help.
> > > 
> > > Any problems yet?
> > 
> > It's ok now... I was waiting some hours (days) to see if it was really ok ;)
> > 
> > Thanks for your help.
> 
> No problem.
> 
> Alan and Jeff, please note, executive summary:
> 
> 1) 'eepro100' driver in 2.4.x + high end EFNET IRC server == crashes
> 2) same as #1 using 'e100' driver == works

My Official Story(tm) is currently

* use e100
* unless you really really want to use eepro100

eepro100 in the kernel tree is essentially unmaintained.  One of the
big reasons I merged e100 is that it has an active maintainer with
full access to docs.

	Jeff
