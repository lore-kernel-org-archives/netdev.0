From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: pull request: wireless 2013-01-09
Date: Thu, 10 Jan 2013 11:14:41 +0100
Message-ID: <CA+icZUV9+JgZcYKZ4DAoj69D89hF-1cqr_bTpJvfgzWZZJ41kQ@mail.gmail.com>
References: <20130109191817.GA17321@tuxdriver.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130109191817.GA17321@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 9, 2013 at 8:18 PM, John W. Linville <linville@tuxdriver.com> wrote:
> Dave,
>
> Please pull this batch of fixes (and a new driver) for the 3.8 stream...
>
> Included is a mac80211 pull, of which Johannes says the following:
>
> 'This includes a number of fixes for various pieces of mac80211. I've
> also included Thomas's memory RMC hash table optimisation since it
> saves so much memory.'
>
> Also from Johannes is an iwlwifi pull:
>
> 'I have two fixes for iwlwifi: one to fix a lost return value that was
> dropped in a previous patch and could cause "nobody cared" IRQ messages,
> and one to work around a firmware issue.'
>
> Amitkumar Karwar brings an mwifiex for a typo in an comparison.
>
> Bing Zhao gives us an mwifiex fix to properly check the return value
> from wait_event_interruptible and handle it properly.
>
> Chen Gang provides a fix to make iwlegacy use strlcpy instead of
> strncpy, avoiding a potential buffer underflow.
>
> Julian Wollrath fixes a typo in an error message in rtlwifi.
>
> Larry Finger brings a b43 fix for a firmware loading problem.
>
> Nickolai Zeldovich avoids a use-after-free in the mwl8k driver.
>
> Vladimir Kondratiev brings the last big piece, the new Qualcomm/Atheros
> wil6210 802.11ad driver.  Since it is for new hardware, I hope that
> taking it for 3.8 is not a problem.
>
> Please let me know if there are problems!
>
> Thanks,
>
> John
>
> ---
>
> The following changes since commit c9be4a5c49cf51cc70a993f004c5bb30067a65ce:
>
>   net: prevent setting ttl=0 via IP_TTL (2013-01-08 17:57:10 -0800)
>
> are available in the git repository at:
>
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-davem
>
> for you to fetch changes up to a9b8a894ad7d0b90b0464c9ac7e8e5c1687edcae:
>
>   Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless into for-davem (2013-01-09 11:01:37 -0500)
>
> ----------------------------------------------------------------

Hi John,

if I look at for-davem GIT branch (online GitWeb interface) [1], this
has no tag "master-2013-01-09" like in master branch.
Comments?

Regards,
- Sedat -

[1] http://git.kernel.org/?p=linux/kernel/git/linville/wireless-next.git;a=shortlog;h=refs/heads/for-davem
