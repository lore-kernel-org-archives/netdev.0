From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-next 2011-08-02
Date: Tue, 02 Aug 2011 17:06:37 -0700 (PDT)
Message-ID: <20110802.170637.389945963010848876.davem@davemloft.net>
References: <20110802181131.GH14167@tuxdriver.com>
	<20110802.143955.1785360722763378138.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110802.143955.1785360722763378138.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Date: Tue, 02 Aug 2011 14:39:55 -0700 (PDT)

> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Date: Tue, 2 Aug 2011 14:11:31 -0400
> 
>> Here are a few more fixes intended for 3.1.  Dan Carpenter gives us an
>> off-by-one fix in the scan trigger code for nl80211.  Felix gives us a
>> fix for tx power initialization for ath9k.  Larry fixes an oops on ARM
>> by rewriting some init code to avoid checking something that doesn't get
>> initialized on ARM.  This round's big hero is Stanislaw, who gives us a
>> brown paper bag fix for some skb handling in rt2x00, an ath9k fix to
>> avoid hangs on systems w/ ASPM disabled, and an iwlegacy fix to ensure
>> that tx power settings are applied properly.
>> 
>> Please let me know if there are problems!
> 
> I'll pull this, but I think once you've sent me all of your features
> for the merge window you should drop "-next" from the name of the
> tree and/or branches you ask me to pull from.
> 
> This makes it entirely clear that you're sending me bug fixes and not
> features and cleanups.

Well, this thing is not based upon the plain net GIT tree, because
when I pull it I get a bunch of things from Linus's tree which are
not in the net tree yet.

Please fix this up.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
