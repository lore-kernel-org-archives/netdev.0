From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] rtnl_unlock/lock in sch_api.c TRY2
Date: Tue, 29 Mar 2005 03:29:01 +0200
Message-ID: <20050329012901.GL3086@postel.suug.ch>
References: <Pine.LNX.4.62.0503290206500.3229@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0503290206500.3229@webhosting.rdsbv.ro>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Catalin(ux aka Dino) BOIE <Pine.LNX.4.62.0503290206500.3229@webhosting.rdsbv.ro> 2005-03-29 02:09
> +	replay:
> +	tcm = NLMSG_DATA(n);
> +	tca = arg;
> +	clid = tcm->tcm_parent;

I know this has been in dave's patch already but why is this needed?
None of these variables changed in the meantime and the netlink message
should still be the same.

> +	q = p = NULL;

There is also no way for q being != NULL here but I don't mind
if this stays as-is, both are supposed to be temporary variables.

Despite of these two comments the patch looks ok to me.
