From: Calvin Owens <jcalvinowens@gmail.com>
Subject: Re: [PATCH] mac80211: ath9k: Use RCU protection calling
 ieee80211_get_tx_rates
Date: Wed, 12 Jun 2013 02:56:34 -0500
Message-ID: <20130612075634.GA1649@gmail.com>
References: <20130609225120.GA2789@gmail.com>
 <20130610042959.GA1902@gmail.com>
 <1370950926.8356.14.camel@jlt4.sipsolutions.net>
 <20130611171304.GA2189@gmail.com>
 <1370980523.8356.70.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Felix Fietkau <nbd@openwrt.org>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	ath9k-devel@lists.ath9k.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1370980523.8356.70.camel@jlt4.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 06/11 at 21:55 +0200, Johannes Berg wrote:
> Now the subject should no longer say "mac80211:" :)
> 
> However... given that ieee80211_get_tx_rates() actually *copies* the
> rates into the parameter, I guess it should do the rcu_read_lock()
> internally. I guess I wasn't paying attention previously. Felix?

I thought about that, but it seemed too simple, so I assumed I was
missing something. ;)

I'll send a patch per above. That makes the header file update
unnecessary too.

> johannes
