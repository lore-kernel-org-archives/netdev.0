From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Best way to hook incoming eth pkts?
Date: Wed, 20 Aug 2003 14:15:12 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030820181512.GE23984@gtf.org>
References: <20030820154727.GB9119@gtf.org> <6756.1061401768@marajade.sandelman.ottawa.on.ca> <20030820175929.GD23984@gtf.org> <20030820105437.73dc86db.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mcr@sandelman.ottawa.on.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030820105437.73dc86db.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Aug 20, 2003 at 10:54:37AM -0700, David S. Miller wrote:
> On Wed, 20 Aug 2003 13:59:29 -0400
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> > On Wed, Aug 20, 2003 at 01:49:28PM -0400, Michael Richardson wrote:
> > >   For ethernet protocols, you can just register the protocol handler, and you
> > > will get them.
> > 
> > Dumb question:  how?  example code, or relevant functions to grep for?
> 
> He's talking about net/core/dev.c:dev_add_pack()

Thanks much.

Tangent, from reading dev.c:  Is it ok that dev_queue_xmit_nit does not
check the return value of struct packet_type's ->func hook?  It seems to
do so in all other cases...

	Jeff
