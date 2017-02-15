From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] average: change to declare precision, not factor
Date: Wed, 15 Feb 2017 12:54:03 -0500 (EST)
Message-ID: <20170215.125403.419777696065228170.davem@davemloft.net>
References: <20170215084926.29482-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
        mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org, sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org, a@unstable.cc,
        sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170215084926.29482-1-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Wed, 15 Feb 2017 09:49:26 +0100

> From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> Declaring the factor is counter-intuitive, and people are prone
> to using small(-ish) values even when that makes no sense.
> 
> Change the DECLARE_EWMA() macro to take the fractional precision,
> in bits, rather than a factor, and update all users.
> 
> While at it, add some more documentation.
> 
> Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> ---
> Unless I hear any objections, I will take this through my tree.

Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
