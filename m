From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: mac80211: tx.c: be sure of 'sdata->vif.type' must
 be NL80211_IFTYPE_AP when be in NL80211_IFTYPE_AP case
Date: Sun, 01 Dec 2013 14:38:19 -0800
Message-ID: <1385937499.2664.21.camel@joe-AO722>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Chen Gang <gang.chen.5i5j@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	rkuo <rkuo@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0178.hostedemail.com ([216.40.44.178]:43673 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751063Ab3LAWiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Dec 2013 17:38:23 -0500
In-Reply-To: <1385890523.4171.1.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-12-01 at 10:35 +0100, Johannes Berg wrote:
> Good try, but no, now ap_sdata isn't even assigned. :)

Right.  Oh well.  There's no improving this without
significant rewrite.  Even then, there may not be much
overall improvement.

btw: Chen, I think fall-throughs are fine as long as
they are commented appropriately.
