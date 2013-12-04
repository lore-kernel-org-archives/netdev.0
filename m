From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: mac80211: tx.c: be sure of 'sdata->vif.type' must
 be NL80211_IFTYPE_AP when be in NL80211_IFTYPE_AP case
Date: Wed, 04 Dec 2013 09:49:37 +0100
Message-ID: <1386146977.4284.11.camel@jlt4.sipsolutions.net>
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
	  <1385995738.20277.4.camel@jlt4.sipsolutions.net>
	  <529E8F90.1020205@gmail.com>
	 (sfid-20131204_031032_173575_B927B340) <1386144281.4284.0.camel@jlt4.sipsolutions.net>
	 <529EEAC1.3010203@gmail.com> (sfid-20131204_093928_179625_C1EF906B)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	rkuo <rkuo@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen.5i5j@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <529EEAC1.3010203@gmail.com> (sfid-20131204_093928_179625_C1EF906B)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-12-04 at 16:41 +0800, Chen Gang wrote:

> According to our original discussion, it seems we agree that I am not
> the suitable member to finish it, so I suggest you or another members to
> try.

There's nothing to finish here. The code is fine. The compiler is wrong,
but we haven't found a way to shut up the compiler without breaking the
code. Please let's just let it rest.

johannes
