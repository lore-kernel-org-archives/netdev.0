From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] (4/4) convert irlan to seq_file interface
Date: Mon, 18 Aug 2003 15:05:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818150514.310f6f5d.shemminger@osdl.org>
References: <20030818122702.67e9162d.shemminger@osdl.org>
	<20030818232554.A7779@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
   "David S. Miller" <davem@redhat.com>, irda-users@lists.sourceforge.net,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20030818232554.A7779@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I did a one step at a time conversion. 

> void irlan_print_filter(struct seq_file *seq, int filter_type)
> {
> 	static struct {
> 		int mask;
> 		char *str;
> 	} filter_mask2str[] = {
> 		{ IRLAN_DIRECTED,	"DIRECTED" },
> 		{ IRLAN_FUNCTIONAL,	"FUNCTIONAL" },
> 		{ IRLAN_GROUP,		"GROUP" },
> 		{ IRLAN_MAC_FRAME,	"MAC_FRAME" },
> 		{ IRLAN_MULTICAST,	"MULTICAST" },
> 		{ IRLAN_BROADCAST,	"BROADCAST" },
> 		{ IRLAN_IPX_SOCKET,	"IPX_SOCKET" },
> 		{ 0,			NULL }
> 	}, *p;
> 
> 	for (p = filter_mask2str; p->str; p++) {
> 		if (filter_type & p->mask)
> 			seq_printf(seq, "%s ", p->str);
> 	}
> 	seq_putc(seq, '\n');
> }

If you are going to do that (and it looks good).  Make the str a const
and use C99 initializers?
