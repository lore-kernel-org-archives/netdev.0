From: "Holden Karau" <holden@pigscanfly.ca>
Subject: Re: [PATCH] wireless-2.6 zd1211rw check against regulatory domain rather than hardcoded value of 11
Date: Mon, 30 Oct 2006 12:49:57 -0500
Message-ID: <f46018bb0610300949i59476730q989c51d1c90e2633@mail.gmail.com>
References: <f46018bb0610231121s4fb48f88l28a6e7d4f31d40bb@mail.gmail.com>
	 <453D48E5.8040100@gentoo.org>
	 <f46018bb0610240709y203d8cdbw95cdf66db23aa1ce@mail.gmail.com>
	 <453E2C9A.7010604@gentoo.org> <4544CBC8.5090305@deine-taler.de>
	 <1162197749.2854.5.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Daniel Drake" <dsd@gentoo.org>, zd1211-devs@lists.sourceforge.net,
	linville@tuxdriver.com, netdev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, holdenk@xandros.com,
	"Johannes Berg" <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161252AbWJ3RuB@vger.kernel.org>
To: kune@deine-taler.de
In-Reply-To: <1162197749.2854.5.camel@ux156>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ulrich,

I'm fairly certain the patch is safe, even for non-US regulatory domains.

Looking at the zd1211rw code the highest channel in the geo object
would appear to be set in zd_geo_init as determined by
zd_channel_range which just does a simple look up in channel_ranges[],
so if this code behaves correctly [and there is no indication it does
not], then setting the upper channel to be that in the geo object
would appear to be safe for any of the supported regulatory domains.

Cheers,

Holden :-)

On 10/30/06, Johannes Berg <johannes@sipsolutions.net> wrote:
>
> > I'm not so sure about this. This patching might be US-specific and we
> > cannot simply apply the setting for top channel of another domain
> > instead of channel 11. One option would be to set the value only under
> > the US regulatory domain.
>
> ??
> What the patch does is replace the top channel which is hardcoded to 11
> by the top channel given by the current regulatory domain. How can that
> be wrong? Except that you may want to init the regulatory domain from
> the EEPROM but I'm not sure how the ieee80211 code works wrt. that.
>
> johannes
>


-- 
Cell: 613-276-1645
