From: Wang YanQing <udknight@gmail.com>
Subject: Re: [PATCH] lib80211: make lib80211 can be enabled independently
Date: Fri, 5 Apr 2013 13:45:19 +0800
Message-ID: <20130405054519.GA2073@udknight>
References: <20130404160130.GA2577@udknight>
 <CAGRGNgXj7mSF0Fgyjek4Xcc34N26WHtt4HMmHk7DOopaEPrYFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	rdunlap@infradead.org
To: Julian Calaby <julian.calaby@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAGRGNgXj7mSF0Fgyjek4Xcc34N26WHtt4HMmHk7DOopaEPrYFw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 05, 2013 at 10:51:30AM +1100, Julian Calaby wrote:
> Just as a bit of explanation for Johannes' NACK:
> 
> 1. The only reason lib80211 still exists is because a couple of
> in-tree drivers still use it. If this weren't the case, the code would
> have been removed a long time ago as it's been completely replaced by
> mac80211 and cfg80211. All modern drivers _must_ use mac80211 or
> cfg80211 without exception.
> 2. In general, there is no official in-kernel support for
> out-of-kernel drivers, regardless of quality, status or importance.
> 3. I believe that the in-tree brcmsmac driver already supports the
> Broadcom card you reference.

Hi Julian.

Thanks for your complete explanation.
I have tried in-tree brcmsmac driver and it works well,
I use it to send out this email! This is wonderful, then
I don't need to fix compilation errors about the old, ugly
and closed wl driver for my notebook with BCM43225 802.11b/g/n
every time I upgrade kernel.

Thanks Julian and all.
