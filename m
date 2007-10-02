From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: Tue, 2 Oct 2007 14:52:36 -0700
Message-ID: <20071002145236.3818bd63@freepuppy.rosehill>
References: <20071002131006.31727.0@janus.isnogud.escape.de>
	<20071002131112.31727.5@janus.isnogud.escape.de>
	<20071002142016.GE7881@ghostprotocols.net>
	<4702B1FD.70102@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Urs Thuermann <urs@isnogud.escape.de>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59572 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752617AbXJBV63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 17:58:29 -0400
In-Reply-To: <4702B1FD.70102@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 02 Oct 2007 23:02:53 +0200
Oliver Hartkopp <oliver@hartkopp.net> wrote:

> Arnaldo Carvalho de Melo wrote:
> > Em Tue, Oct 02, 2007 at 03:10:11PM +0200, Urs Thuermann escreveu:
> >   
> >> +
> >> +#ifdef CONFIG_CAN_DEBUG_DEVICES
> >> +static int debug;
> >> +module_param(debug, int, S_IRUGO);
> >> +#endif
> >>     
> >
> > Can debug be a boolean? Like its counterpart on DCCP:
> >
> > net/dccp/proto.c:
> >
> > module_param(dccp_debug, bool, 0444);
> >   
> 
> 'debug' should remain an integer to be able to specifiy debug-levels or 
> bit-fields for different Debug outputs.
> 
> > Where we also use a namespace prefix, for those of us who use ctags or
> > cscope.
> >   
> 
> Even if i don't have any general objections to rename this 'debug' to 
> 'vcan_debug', it looks like an 'overnamed' module parameter for me. Is 
> this a genereal naming scheme recommendation for debug module_params?
> 

Please consider using netif_msg_xxx() and module parameter to set
default message level, like other real network drivers already do.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
