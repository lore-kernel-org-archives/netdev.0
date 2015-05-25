From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull-request: wireless-drivers-next 2015-05-21
Date: Sun, 24 May 2015 23:29:55 -0400 (EDT)
Message-ID: <20150524.232955.425320477500361631.davem@davemloft.net>
References: <87k2w26oef.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87k2w26oef.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Date: Thu, 21 May 2015 16:39:04 +0300

> here's a wireless-drivers pull request for 4.2. This time please pay
> extra attention to this pull as there are two problems:
> 
> First of all as you can see the diffstat from git-pull-request in the
> end is just weird. I was long and hard trying to check everything and to
> my understanding all the merges look ok and I cannot explain the reason
> for the diffstat, but of course I might be missing something. Maybe
> git-request-pull is just buggy? At least with gitk everything looks to
> be ok and the patch list below also looks valid.

The diffstat doesn't look anything like that for me.  It contained only
your wireless changes.

It may have helped that I merged 'net' into 'net-next' right before I
pulled this.

> Secondly there's a non-trivial conflict in
> drivers/net/wireless/ath/ath10k/mac.c which is due to removal of
> FIF_PROMISC_IN_BSS in commit df1404650c. You need to remove more code
> than just the obvious conflicts shown by git. In the end of this mail I
> added a git diff output after I fixed the conflict, hopefully that helps
> you to fix it. The main points are that you remove
> ath10k_mac_should_disable_promisc() and the last ath10k_monitor_recalc()
> call from ath10k_vdev_start_restart() along with the obvious conflict
> fixes git points out.
> 
> There's also a patch from Michal which will also help to fix the
> resolution. Michal, please double check the resolution proposal below so
> that I didn't miss anything.
> 
> https://patchwork.kernel.org/patch/6387631/

Thanks, I think I got the conflict resolution correct, please have a look.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
