From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] mac80211: minstrel_ht: fix out-of-bound in
 minstrel_ht_set_best_prob_rate
Date: Tue, 02 Feb 2016 15:55:20 +0100
Message-ID: <1454424920.2926.2.camel@sipsolutions.net>
References: <145405651192.4948.10685647900939287282.stgit@zurg>
	 (sfid-20160129_093515_897484_5ED72DF7)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Thomas Huehn <thomas-rDH2yu9ArSPZY3qUpHLZ+xQ0avMEgXv9@public.gmane.org>
To: Konstantin Khlebnikov <koct9i-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <145405651192.4948.10685647900939287282.stgit@zurg> (sfid-20160129_093515_897484_5ED72DF7)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-01-29 at 11:35 +0300, Konstantin Khlebnikov wrote:
> Patch fixes this splat
> 
> BUG: KASAN: slab-out-of-bounds in
> minstrel_ht_update_stats.isra.7+0x6e1/0x9e0
> [mac80211] at addr ffff8800cee640f4 Read of size 4 by task
> swapper/3/0
> 
> Signed-off-by: Konstantin Khlebnikov <koct9i-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Link: http://lkml.kernel.org/r/CALYGNiNyJhSaVnE35qS6UCGaSb2Dx1_i5HcRa
> vuOX14oTz2P+w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org
> 

Applied, thanks.

johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
