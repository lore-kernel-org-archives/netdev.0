From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] mac80211: Remove unused 'struct rate_control_ref'
 variable
Date: Tue, 22 Nov 2016 08:30:30 +0100
Message-ID: <1479799830.4391.6.camel@sipsolutions.net>
References: <20161122065416.GA3565@google.com>
         (sfid-20161122_075424_196465_55445AD4)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Maxim Altshul <maxim.altshul-l0cyMroinI0@public.gmane.org>
To: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161122065416.GA3565-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> (sfid-20161122_075424_196465_55445AD4)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-11-21 at 22:54 -0800, Kirtika Ruchandani wrote:
> Commit 3b17fbf87d5d introduced sta_get_expected_throughput()
> leaving variable 'struct rate_control_ref* ref' set but unused.
> Compiling with W=1 gives the following warning, fix it.
> 
> net/mac80211/sta_info.c: In function ‘sta_set_sinfo’:
> net/mac80211/sta_info.c:2052:27: warning: variable ‘ref’ set but not
> used [-Wunused-but-set-variable]

Applied all three of these, thanks Kirtika.

johannes
