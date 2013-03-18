From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] bluetooth: use PTR_RET instead of IS_ERR + PTR_ERR
Date: Mon, 18 Mar 2013 14:08:10 -0400 (EDT)
Message-ID: <20130318.140810.1336756541135122611.davem@davemloft.net>
References: <1363111995-26866-1-git-send-email-silviupopescu1990@gmail.com>
	<20130313.053145.2200448840921851390.davem@davemloft.net>
	<CAPWTe+JzznuWYKksAfxkD=u9kv8DuAF4v2AWVxd2OUeDtCYKBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org, johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: silviupopescu1990-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAPWTe+JzznuWYKksAfxkD=u9kv8DuAF4v2AWVxd2OUeDtCYKBA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Silviu Popescu <silviupopescu1990-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 18 Mar 2013 20:05:42 +0200

>>> +     return PTR_RET(bt_class)
 ..
> That being said, I'd like to understand a bit better what exactly I messed up.

There's no semicolon at the end of the return statement.
