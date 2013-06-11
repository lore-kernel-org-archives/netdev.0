From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: ath9k: Use RCU protection calling
 ieee80211_get_tx_rates
Date: Tue, 11 Jun 2013 21:55:23 +0200
Message-ID: <1370980523.8356.70.camel@jlt4.sipsolutions.net>
References: <20130609225120.GA2789@gmail.com>
	 <20130610042959.GA1902@gmail.com>
	 <1370950926.8356.14.camel@jlt4.sipsolutions.net>
	 <20130611171304.GA2189@gmail.com> (sfid-20130611_191323_492868_156158C4)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Felix Fietkau <nbd@openwrt.org>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	ath9k-devel@lists.ath9k.org, netdev@vger.kernel.org
To: Calvin Owens <jcalvinowens@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130611171304.GA2189@gmail.com> (sfid-20130611_191323_492868_156158C4)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now the subject should no longer say "mac80211:" :)

However... given that ieee80211_get_tx_rates() actually *copies* the
rates into the parameter, I guess it should do the rcu_read_lock()
internally. I guess I wasn't paying attention previously. Felix?

johannes
