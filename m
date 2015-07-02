From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: bluetooth 2015-07-02
Date: Thu, 02 Jul 2015 12:18:21 -0700 (PDT)
Message-ID: <20150702.121821.1272949529563088472.davem@davemloft.net>
References: <20150702073038.GA25214@t440s.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150702073038.GA25214-ypHiNAJIRA7/PtFMR13I2A@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 2 Jul 2015 10:30:38 +0300

> A couple of regressions crept in because of a patch to use proper list
> APIs rather than manually reading & writing the next/prev pointers
> (commit 835a6a2f8603237a3e6cded5a6765090ecb06ea5). Turns out this was
> masking a few bugs: a missing INIT_LIST_HEAD() call and incorrectly
> using list_del() rather than list_del_init(). The two patches in this
> set fix these, and it'd be nice they could still make it to 4.2-rc1 to
> avoid new bug reports from users.
> 
> Please let me know if there are any issues pulling. Thanks.

Pulled, thanks Johan.
