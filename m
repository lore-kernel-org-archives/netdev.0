From: "Venkataraman, Meenakshi" <meenakshi.venkataraman-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: net-next iwlwifi breaks compile - was Re: pull request:
 wireless-next 2012-04-18
Date: Thu, 19 Apr 2012 19:47:58 +0000
Message-ID: <4595B4D22AB93C4FABBA84AAD5AA37FD1258AA@ORSMSX103.amr.corp.intel.com>
References: <20120418190521.GB2436@tuxdriver.com>
 <20120418.153653.2130740499995307564.davem@davemloft.net>
 <4F8F9977.9040703@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Spinadel, David" <david.spinadel-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Guy, Wey-Yi W" <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F8F9977.9040703-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hey Oliver,

>Commit "iwlwifi: move scan related declarations out of iwl-core.h"
>
>http://git.kernel.org/?p=linux/kernel/git/davem/net-
>next.git;a=commitdiff;h=8fb96d6e176cbf0a97b2391fa1fa09e608ee86f8
>
>breaks the compile when CONFIG_IWLWIFI_DEBUGFS is not set, see:

[MV] Sorry about breaking net-next. I took a look at the patch that you've pointed to, and actually it's a patch that caused the problem. The commit that broke it is actually:

iwlwifi: expose static methods for MVM use

http://git.kernel.org/?p=linux/kernel/git/davem/net-next.git;a=commit;h=50c1e9a9e3b086465b1467d448c10f7fa1e0eb5c

It was fixed internally in a subsequent patch, but that patch has not made it into net-next. I don't see it in the public iwlwifi repository either. We'll add the fix to the repository so you can pick it up.

Thanks & sorry,
Meenakshi



--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
