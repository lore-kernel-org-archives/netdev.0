From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: mac80211: tx.c: be sure of 'sdata->vif.type' must
 be NL80211_IFTYPE_AP when be in NL80211_IFTYPE_AP case
Date: Mon, 02 Dec 2013 15:48:58 +0100
Message-ID: <1385995738.20277.4.camel@jlt4.sipsolutions.net>
References: <528AEFB7.4060301@gmail.com>
	 <20131125011938.GB18921@codeaurora.org> <5292B845.3010404@gmail.com>
	 <5292B8A0.7020409@gmail.com> <5294255E.7040105@gmail.com>
	 <52957ADA.2080704@gmail.com>
	 (sfid-20131127_055211_558798_A7DF5684) <1385739487.8656.1.camel@jlt4.sipsolutions.net>
	 <5299D306.7070701@gmail.com>
	 (sfid-20131130_125901_519610_EDA4068E) <1385816013.4327.1.camel@jlt4.sipsolutions.net>
	 <5299ED38.4090509@gmail.com> <5299EFDD.6060405@gmail.com>
	 (sfid-20131130_150205_984535_068F14A9) <1385842134.6108.4.camel@jlt4.sipsolutions.net>
	 <1385843940.2664.4.camel@joe-AO722>
	 <1385890523.4171.1.camel@jlt4.sipsolutions.net>
	 <1385937499.2664.21.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Chen Gang <gang.chen.5i5j@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	rkuo <rkuo@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1385937499.2664.21.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-12-01 at 14:38 -0800, Joe Perches wrote:
> On Sun, 2013-12-01 at 10:35 +0100, Johannes Berg wrote:
> > Good try, but no, now ap_sdata isn't even assigned. :)
> 
> Right.  Oh well.  There's no improving this without
> significant rewrite.  Even then, there may not be much
> overall improvement.

I could see an improvement if we were to actually make changes to assign
the pointer based on the iftype, when that changes, so that each
function only has to handle the right type and we don't need the switch
statement at all...

But that's tricky to get right and I'm between vacations and holidays
and all that ...

johannes
