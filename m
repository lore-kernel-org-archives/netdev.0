From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: e100 "Ferguson" release
Date: Tue, 5 Aug 2003 07:28:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E01022292A3@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > if(unlikely(e100_exec_cb(nic, skb, e100_xmit_prepare) == -ENOMEM)) {
> >         netif_stop_queue(netdev);
> >         nic->net_stats.tx_dropped++;
> >         dev_kfree_skb(skb);
> >         return 0;
> > }
> 
> Yes.  I would also printk(KERN_ERR "we have a bug!") or 
> somesuch, like several other drivers do, too.

It's there, sorry, was trying to keep the code snippet small.

> >>* (minor) use a netif_msg_xxx wrapper/constant in
> >>e100_init_module test?
> > 
> > 
> > Can't - don't have nic->msg_enable allocated yet.  :(
> 
> You could always use "(1 << debug) - 1"... :)  I dunno if it's worth 
> worrying about.

(1 << debug) - 1) & NETIF_MSG_DRV is what's there now.

-scott
