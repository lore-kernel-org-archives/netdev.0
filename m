From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [patch net-next V6 00/15] net: introduce upper device lists
 and remove dev->master
Date: Fri, 04 Jan 2013 13:33:31 -0800 (PST)
Message-ID: <20130104.133331.1729083969241157711.davem@davemloft.net>
References: <1357289343-817-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
	divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, jitendra.kalsaria-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
	sony.chacko-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	ursula.braun-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, blaschka-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org,
	bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org, therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org,
	gregory.v.rose-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1357289343-817-1-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Date: Fri,  4 Jan 2013 09:48:48 +0100

> This patchset adds a possibility to record upper device linkage.
> All upper<->lower devices are converted to use this mechanism right after.
> That leads to dev->master removal because this info becomes redundant since
> "master links" have the same value.

Series applied, thanks Jiri.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
