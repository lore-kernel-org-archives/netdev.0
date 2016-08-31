From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH 1/2] NFSv4.1: work around -Wmaybe-uninitialized warning
Date: Wed, 31 Aug 2016 15:37:28 +0200
Message-ID: <5024842.0SZmq2hZxe@wuerfel>
References: <20160831123911.3467676-1-arnd@arndb.de> <9F99A562-A4F6-457A-A78F-44BAC3B5734F@primarydata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Schumaker Anna <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
        List Linux Network Devel Mailing <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        List Linux NFS Mailing <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        List Linux Kernel Mailing <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Trond Myklebust <trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <9F99A562-A4F6-457A-A78F-44BAC3B5734F-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday, August 31, 2016 1:17:48 PM CEST Trond Myklebust wrote:
> What version of gcc are you using? I’m unable to reproduce with gcc 6.1.1..

This is also on 6.1.1 for ARM. Note that 6e8d666e9253 ("Disable
"maybe-uninitialized" warning globally") turned off those warnings, so
unless you explicitly pass -Wmaybe-uninitialized (e.g. by building with
"make W=1"), you won't get it.

The reason I'm still sending the patches for this warning is that
we do get a number of valid ones (this was the only false positive
out of the seven such warnings since last week).

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
