From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH PKT_SCHED 11/17]: Remove checks for impossible conditions in ipt action
Date: Thu, 30 Dec 2004 14:40:29 +0100
Message-ID: <20041230134029.GX32419@postel.suug.ch>
References: <41D378AB.70204@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41D378AB.70204@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <41D378AB.70204@trash.net> 2004-12-30 04:40
> -	if (a == NULL || rta == NULL ||
> -	    rtattr_parse(tb, TCA_IPT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
> +	if (rtattr_parse(tb, TCA_IPT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
>  		return -1;

You might want to use rtattr_parse_nested here (see patch 1 of my latest
patchset)

if (rtattr_parse_nested(tb, TCA_IPT_MAX, rta) < 0)

Purely cosmetic though. It gives a slightly better hint on what is being
done.
