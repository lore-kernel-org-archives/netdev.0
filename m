From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] qdisc oops fix
Date: Tue, 15 Apr 2003 20:53:28 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030415205232.Y4013@shell.cyberus.ca>
References: <Pine.LNX.4.44.0304160132130.1322-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tomas Szepe <szepe@pinerecords.com>, "" <netdev@oss.sgi.com>,
   Martin Devera <devik@cdi.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0304160132130.1322-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Yep. That looks like the problem. Thanks for narrowing it down Julian.

cheers,
jamal


On Wed, 16 Apr 2003, Julian Anastasov wrote:

>
> 	Hello,
>
> 	May be this is not the right fix:
>
> > -       sch = kmalloc(size, GFP_KERNEL);
> > +       sch = kmalloc(size, GFP_ATOMIC);
>
> 	better Devik to provide fix for htb_change_class that will not
> call qdisc_create_dflt under bh lock (sch_tree_lock).
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>
>
