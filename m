From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [BUG] unable to handle kernel NULL pointer dereference
Date: Sun, 16 Feb 2014 18:35:47 +0100
Message-ID: <20140216173547.GC25047@pd.tnic>
References: <1392466251.41282.YahooMailNeo@web140003.mail.bf1.yahoo.com>
 <1392494917.71728.YahooMailNeo@web140002.mail.bf1.yahoo.com>
 <20140215203015.GA4528@pd.tnic>
 <1392498262.98385.YahooMailNeo@web140003.mail.bf1.yahoo.com>
 <20140215232508.GB4508@pd.tnic>
 <1392571653.44773.4.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	John <da_audiophile-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>,
	lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org" <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
	"mlindner-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org" <mlindner-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
To: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1392571653.44773.4.camel-5lNtUQgoD8Pfa3cDbr2K10B+6BGkLq7r@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 16, 2014 at 12:27:33PM -0500, Trond Myklebust wrote:
> Please ensure that you post to the linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org when
> reporting NFS and RPC related bugs.

Sorry, get_maintainer.pl gave it too but far down in an already too
long list and I wasn't sure who to spam so I picked up supporter and
maintainer:

$ ./scripts/get_maintainer.pl -f net/sunrpc/auth_gss/auth_gss.c
"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> (supporter:KERNEL NFSD, SUNR...,commit_signer:3/26=12%)
Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org> (maintainer:NFS, SUNRPC, AND...,commit_signer:24/26=92%,authored:14/26=54%,added_lines:394/475=83%,removed_lines:189/215=88%)
"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (maintainer:NETWORKING [GENERAL])
Andy Adamson <andros-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org> (commit_signer:3/26=12%,authored:3/26=12%,added_lines:56/475=12%)
Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> (commit_signer:3/26=12%,authored:3/26=12%)
Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (commit_signer:3/26=12%,authored:3/26=12%,removed_lines:19/215=9%)
linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:KERNEL NFSD, SUNR...)
netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:NETWORKING [GENERAL])
linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list)

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
