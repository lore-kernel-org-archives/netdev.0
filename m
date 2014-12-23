From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH RFC] ipw2200: select CFG80211_WEXT
Date: Tue, 23 Dec 2014 11:20:55 +0100
Message-ID: <1419330055.30945.76.camel@x220>
References: <1419271817.2317.12.camel@tiscali.nl>
	 <871tnqhn7j.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes.berg@intel.com>,
	Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <871tnqhn7j.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-12-23 at 08:52 +0200, Kalle Valo wrote:
> Paul Bolle <pebolle@tiscali.nl> writes:
> 
> > Commit 24a0aa212ee2 ("cfg80211: make WEXT compatibility unselectable")
> > made it impossible to depend on CFG80211_WEXT. It does still allow to
> > select that symbol. (Yes, the commit summary is confusing.)
> >
> > So make IPW2200 select CFG80211_WEXT, so that the ipw2200 driver can be
> > built again.
> 
> I think the last sentence is a bit misleading (this isn't a compilation
> error, right?)

No, it's not a compilation error.

The reasoning here is that all code hidden behind a Kconfig symbol that
cannot be set will, in practice, never be built. Sure, there are hoops
one can jump through to try to bypass the generated .config, but no one
should have to do that.

>  and I would like to clarify it like this:
> 
> "So make IPW2200 select CFG80211_WEXT, so that the ipw2200 driver can be
> enabled in config again."
> 
> Does that look ok?

I understand the confusion my text might cause, so I'm fine with your
amendment.

Thanks,


Paul Bolle
