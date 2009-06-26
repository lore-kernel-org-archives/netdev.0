From: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Subject: Re: [2.6.31-rc1] iwlagn (4965): no wireless due to RFKILL problem
Date: Fri, 26 Jun 2009 14:10:57 +0200
Message-ID: <200906261410.58808.elendil@planet.nl>
References: <200906261336.29318.elendil@planet.nl> <8db1092f0906260459n308311faweb6d9733cdd1eb13@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alan Jenkins <alan-jenkins-cCz0Lq7MMjm9FHfhHBbuYA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
To: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <8db1092f0906260459n308311faweb6d9733cdd1eb13-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 26 June 2009, Maciej Rutecki wrote:
> 2009/6/26 Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>:
> > I've tried .31-rc1 on my HP 2510p notebook and the only problem I
> > found was that wireless no longer works. The cause looks to be
> > related to RFKILL.
>
> Same on HP/Compaq nx6310, caused by hp-wmi module. It's disable
> bluetooth and wireless. I must turn it on in Windows XP (in HP tools).
> Workaround: don't load hp-wmi. Already I try find how enable it via
> /sys like in Windows.

Thanks for narrowing it down.

Well, with 2.6.30 hp-wmi worked together with rfkill without problems.
Looking at the commit logs, it looks like the rfkill rewrite by Johannes 
and Alan is the cause here. CCs added.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
