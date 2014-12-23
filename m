From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH RFC] ipw2200: select CFG80211_WEXT
Date: Tue, 23 Dec 2014 08:52:48 +0200
Message-ID: <871tnqhn7j.fsf@kamboji.qca.qualcomm.com>
References: <1419271817.2317.12.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes.berg@intel.com>,
	Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419271817.2317.12.camel@tiscali.nl> (Paul Bolle's message of
	"Mon, 22 Dec 2014 19:10:17 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul Bolle <pebolle@tiscali.nl> writes:

> Commit 24a0aa212ee2 ("cfg80211: make WEXT compatibility unselectable")
> made it impossible to depend on CFG80211_WEXT. It does still allow to
> select that symbol. (Yes, the commit summary is confusing.)
>
> So make IPW2200 select CFG80211_WEXT, so that the ipw2200 driver can be
> built again.

I think the last sentence is a bit misleading (this isn't a compilation
error, right?) and I would like to clarify it like this:

"So make IPW2200 select CFG80211_WEXT, so that the ipw2200 driver can be
enabled in config again."

Does that look ok?

-- 
Kalle Valo
