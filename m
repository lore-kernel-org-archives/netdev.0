From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: mac80211: tx.c: be sure of 'sdata->vif.type' must
 be NL80211_IFTYPE_AP when be in NL80211_IFTYPE_AP case
Date: Sun, 01 Dec 2013 10:37:27 +0100
Message-ID: <1385890647.4171.3.camel@jlt4.sipsolutions.net>
References: <528AEFB7.4060301@gmail.com>
	  <20131125011938.GB18921@codeaurora.org> <5292B845.3010404@gmail.com>
	  <5292B8A0.7020409@gmail.com> <5294255E.7040105@gmail.com>
	  <52957ADA.2080704@gmail.com>
	  (sfid-20131127_055211_558798_A7DF5684) <1385739487.8656.1.camel@jlt4.sipsolutions.net>
	  <5299D306.7070701@gmail.com>
	  (sfid-20131130_125901_519610_EDA4068E) <1385816013.4327.1.camel@jlt4.sipsolutions.net>
	  <5299ED38.4090509@gmail.com> <5299EFDD.6060405@gmail.com>
	  (sfid-20131130_150205_984535_068F14A9) <1385842134.6108.4.camel@jlt4.sipsolutions.net>
	 <1385843940.2664.4.camel@joe-AO722> <529A7955.9010507@gmail.com>
	 (sfid-20131201_004838_825869_AF1FBAAC)
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:34157 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751229Ab3LAJhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Dec 2013 04:37:34 -0500
In-Reply-To: <529A7955.9010507@gmail.com> (sfid-20131201_004838_825869_AF1FBAAC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-12-01 at 07:48 +0800, Chen Gang wrote:

> If ieee80211_subif_start_xmit() is not performance sensitive (I guess
> so), we can use some short static functions instead of some code blocks
> within ieee80211_subif_start_xmit().
> 
>  - ieee80211_subif_start_xmit() is a long function (600+ lines).
> 
>  - use short static function can share some code.
> 
>  - if code can be shared, the work flow can be more clearer too (don't
>    need fall-through or goto).

Frankly, I'm getting tired of discussing this. Please don't try to
rewrite this code until you've understood it. You suggesting that
"start_xmit()" isn't a performance sensitive function makes me realize
you haven't even tried.

johannes
