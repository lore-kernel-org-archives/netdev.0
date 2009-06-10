From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 0/5] We must use rcu_barrier() on module unload
Date: Wed, 10 Jun 2009 01:11:55 -0700 (PDT)
Message-ID: <20090610.011155.231596832.davem@davemloft.net>
References: <20090608130959.10052.54590.stgit@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org,
	oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org,
	vladislav.yasevich-VXdhtT5mjnY@public.gmane.org, sri-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: hawk-4UpuNZONu4c@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090608130959.10052.54590.stgit@localhost>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
Date: Mon, 08 Jun 2009 15:11:23 +0200

> If an unloadable module uses RCU callbacks, it need to use
> rcu_barrier() so that the module may be safely unloaded.
 ...
> The patchset is made on top of DaveM's net-next-2.6 tree (starting on
> top of commit a1c1db392090). As this is my usual development tree,
> even though this patchset is bugfixes. (Just tested it applied cleanly
> on Linus'es tree ...)

All 5 patches applied, thanks!
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
