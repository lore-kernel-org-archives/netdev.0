From: Corey Richardson <corey@octayn.net>
Subject: Re: mac80211: regression: fd0f979 no long authenticates w/ath9k_htc
Date: Tue, 5 Mar 2013 16:49:29 -0500
Message-ID: <CA++BO6QA9cFmM2kU4u8ASxWqJeGwUB1385awKfXLP=O0fA87NA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Johannes Berg <johannes.berg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 4, 2013 at 3:42 AM, Corey Richardson <corey@octayn.net> wrote:
> ath9k_htc driver , AR9271 (at least according to lsusb)
>
> commit fd0f979a1b67f0889aea24a7c7d2a54d6706a1cf
> Author: Johannes Berg <johannes.berg@intel.com>
> Date:   Thu Feb 7 00:14:51 2013 +0100
>
>     mac80211: simplify idle handling
>
>     Now that we have channel contexts, idle is (pretty
>     much) equivalent to not having a channel context.
>     Change the code to use this relation so that there
>     no longer is a need for a lot of idle recalculate
>     calls everywhere.
>
>     Signed-off-by: Johannes Berg <johannes.berg@intel.com>
>
> :040000 040000 85b3d4d114efb012773b4c7e1728b5bcae2e6b37
> 3ff33170763520b03e84e067f91cc0a8334e4d36 M    net
>
> any more info needed?

I noticed the mail didn't get through to all lists, perhaps the
attachments were too large? (~135K)

Files are at https://gist.github.com/cmr/a5ace41e765fca073201
