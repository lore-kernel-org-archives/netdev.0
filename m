From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC 0/2] generic netlink doit generalisation
Date: Fri, 01 Oct 2010 00:39:38 +0200
Message-ID: <1285886378.5137.27.camel@jlt3.sipsolutions.net>
References: <20100930211013.472957770@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100930211013.472957770-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-09-30 at 23:10 +0200, Johannes Berg wrote:
> nl80211 does a lot of boilerplate work
> for each generic netlink doit() operation,
> this is an attempt to reduce it.

Here are the completed versions of the nl80211 cleanups:

http://johannes.sipsolutions.net/patches/kernel/all/LATEST/NNN-nl80211-use-pre-post.patch
http://johannes.sipsolutions.net/patches/kernel/all/LATEST/NNN-nl80211-generic-running.patch

The combined diffstat of these two is

 net/wireless/nl80211.c | 1756 +++++++++++++++----------------------------------
 1 file changed, 541 insertions(+), 1215 deletions(-)

and they reduce code size by >4k on my x86_64 compile.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
