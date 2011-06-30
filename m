From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net/core: Convert to current logging forms
Date: Thu, 30 Jun 2011 10:10:37 -0700
Message-ID: <1309453837.7277.3.camel@Joe-Laptop>
References: <385ebf7e98e377e6e6c384beb961b65d4a95fb18.1309289792.git.joe@perches.com>
	 <iuhh76$fid$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: WANG Cong <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <iuhh76$fid$1@dough.gmane.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-06-30 at 09:55 +0000, WANG Cong wrote:
> On Tue, 28 Jun 2011 12:40:10 -0700, Joe Perches wrote:
> > Use pr_fmt, pr_<level>, and netdev_<level> as appropriate.
> > Coalesce long formats.
> > +		np->name, np->local_port);
> > +	pr_info("%s: local IP %pI4\n",
> > +		np->name, &np->local_ip);
> > +	pr_info("%s: interface '%s'\n",
> > +		np->name, np->dev_name);
> > +	pr_info("%s: remote port %d\n",
> > +		np->name, np->remote_port);
> > +	pr_info("%s: remote IP %pI4\n",
> > +		np->name, &np->remote_ip);
> > +	pr_info("%s: remote ethernet address %pM\n",
> > +		np->name, np->remote_mac);
> >  }
> This doesn't have much value, because the name of the netpoll
> user (np->name) is already logged. If we changed it,
> we would see "netconsole: netconsole: blah blah...".

Thanks.

Don't just reply to the lists.
Remember to include the patch author in your replies.

cheers, Joe
