From: "David S. Miller" <davem@redhat.com>
Subject: Re: Best way to hook incoming eth pkts?
Date: Wed, 20 Aug 2003 11:17:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030820111716.1329256b.davem@redhat.com>
References: <20030820154727.GB9119@gtf.org>
	<6756.1061401768@marajade.sandelman.ottawa.on.ca>
	<20030820175929.GD23984@gtf.org>
	<20030820105437.73dc86db.davem@redhat.com>
	<20030820181512.GE23984@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mcr@sandelman.ottawa.on.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20030820181512.GE23984@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 20 Aug 2003 14:15:12 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Tangent, from reading dev.c:  Is it ok that dev_queue_xmit_nit does not
> check the return value of struct packet_type's ->func hook?  It seems to
> do so in all other cases...

The return value isn't really used currently.
It provides congestion heuristics that maybe eventually
will be taken advantage of.
