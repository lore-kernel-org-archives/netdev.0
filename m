From: "Luis R. Rodriguez" <mcgrof-kCJ/WVjk54vrZ44/DZwexQ@public.gmane.org>
Subject: Re: compat-wireless releases based on v3.3
Date: Wed, 28 Mar 2012 00:43:36 -0700
Message-ID: <CAB=NE6WFM-BPQ41kPaod-7qkHnT5MXCUc2hdKXDVzrdPq2brjA@mail.gmail.com>
References: <CAB=NE6WgTMdDtU4_ZgYVr2XzSuiicT5o=q2RvV24jeQj0rZfFw@mail.gmail.com>
 <4F72BB7F.8080704@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-bluetooth <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	lf_driver_backport-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Farina <sidhayn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F72BB7F.8080704-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 28, 2012 at 12:19 AM, Richard Farina <sidhayn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> /var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/carl9170/tx.c:
> In function 'carl9170_tx_ps_drop':
> /var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/carl9170/tx.c:1248:26:
> error: 'IEEE80211_TX_CTL_POLL_RESPONSE' undeclared (first use in this
> function)

linux-next-cherry-picks/0007-mac80211-handle-non-bufferable-MMPDUs-correctly.patch

is to be blamed for. This is fixed, new tarball:

http://www.orbit-lab.org/kernel/compat-wireless-3-stable/v3.3/compat-wireless-3.3-2-n.tar.bz2
sha1sum: dd18cfabbe705a75440fd7fbe50a09d5fe34bb70

Thanks for reporting this. Just FYI -- I am working to use ckmake on
compat-wireless.git to build test against all supported kernels prior
to release just as I am doing now for compat.git, but the current
development cycle still a few items which require a bit of work to
backport to fix compilation against older kernels. That is the goal
though, so that future releases area always guaranteed to compile
against all supported stable kernel releases listed on kernel.org.

  Luis
