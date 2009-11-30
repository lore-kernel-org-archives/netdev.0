From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: pull request: wireless-2.6 2009-11-30 (security fixes too)
Date: Mon, 30 Nov 2009 14:08:21 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0911301406230.2872@localhost.localdomain>
References: <20091130194706.GE21401@tuxdriver.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753221AbZK3WI5@vger.kernel.org>
In-Reply-To: <20091130194706.GE21401@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 30 Nov 2009, John W. Linville wrote:
> 
> If a) you have already taken Dave's latest pull request; and, b) you
> don't want to wait for his next one to get the mac80211 security fixes
> from Johannes, then you can at your discretion pull from here:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git security

Hmm. If I pull the 'security' branch, I get

 drivers/net/wireless/iwlwifi/iwl-tx.c |   10 +++++++++-
 include/net/mac80211.h                |    6 ++++++
 net/mac80211/agg-rx.c                 |    4 ----
 net/mac80211/agg-tx.c                 |   17 ++++++++---------
 net/mac80211/ht.c                     |    8 +++-----
 net/mac80211/ieee80211_i.h            |    2 ++
 6 files changed, 28 insertions(+), 19 deletions(-)

which does not match what you then descibe in the rest of the email 
(changelog and diffstat).

What you describe seems to be the master branch. 

So I'm not going to pull either, and will wait for confirmation of exactly 
what you wanted me to pull.

				Linus
