From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: Please pull 'upstream-davem' branch of wireless-2.6
Date: Tue, 02 Oct 2007 19:01:56 -0700 (PDT)
Message-ID: <20071002.190156.41633562.davem@davemloft.net>
References: <20071003012552.GE29361@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071003012552.GE29361-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Tue, 2 Oct 2007 21:25:52 -0400

>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-davem

This doesn't pull cleanly.

Probably you used a recently cloned Linus tree, pulled
net-2.6.24 into that (and resolved the conflicts), and
then put your patches in.

Please don't do it like that, I don't want to pull from
a tree that has linus vs. net-2.6.24 conflict handling
in it.  That's why I usually rebase frequently, to minimize
that as much as is humanly possible.

What you can do is figure out what linus's HEAD was at the last rebase
(basically 'origin' or parent of net-2.6.24), clone that then pull in
net-2.6.24, then add your patches.

That way I can always do a clean pull.

My pull from Jeff today was very clean, for example.

I'll add these wireless bits by hand as patches.

Thanks John.
