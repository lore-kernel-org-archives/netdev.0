From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH RFC] ipw2200: select CFG80211_WEXT
Date: Tue, 23 Dec 2014 11:28:41 +0100
Message-ID: <1419330521.6091.1.camel@sipsolutions.net>
References: <1419271817.2317.12.camel@tiscali.nl>
	 (sfid-20141222_191040_534124_837C59D7)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419271817.2317.12.camel@tiscali.nl> (sfid-20141222_191040_534124_837C59D7)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-12-22 at 19:10 +0100, Paul Bolle wrote:
> Commit 24a0aa212ee2 ("cfg80211: make WEXT compatibility unselectable")
> made it impossible to depend on CFG80211_WEXT. It does still allow to
> select that symbol. (Yes, the commit summary is confusing.)
> 
> So make IPW2200 select CFG80211_WEXT, so that the ipw2200 driver can be
> built again.
> 
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
> ---
> Johannes,
> 
> Building v3.19-rc1 for an outdated ThinkPad X41 left me without the
> ipw2200 driver. It turns out this trivial patch is all that's needed to
> make ipw2200 buildable again.
> 
> (A similar patch would be needed for the drivers behind Kconfig symbol
> HERMES. Ie, orinico and friends.) 

Yeah, config HERMES needs the same change.

Kalle, do you want to take those through your tree, or should I fix it
seeing that I introduced the bug in a sense?

johannes
