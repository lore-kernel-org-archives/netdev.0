From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] qdisc oops fix
Date: Wed, 16 Apr 2003 01:42:43 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0304160132130.1322-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, jamal <hadi@cyberus.ca>, Martin Devera <devik@cdi.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: Tomas Szepe <szepe@pinerecords.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

	May be this is not the right fix:

> -       sch = kmalloc(size, GFP_KERNEL);
> +       sch = kmalloc(size, GFP_ATOMIC);

	better Devik to provide fix for htb_change_class that will not 
call qdisc_create_dflt under bh lock (sch_tree_lock).

Regards

--
Julian Anastasov <ja@ssi.bg>
