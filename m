From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH] lib80211: make lib80211 can be enabled independently
Date: Fri, 5 Apr 2013 10:51:30 +1100
Message-ID: <CAGRGNgXj7mSF0Fgyjek4Xcc34N26WHtt4HMmHk7DOopaEPrYFw@mail.gmail.com>
References: <20130404160130.GA2577@udknight>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Wang YanQing <udknight@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130404160130.GA2577@udknight>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Wang,

On Fri, Apr 5, 2013 at 3:01 AM, Wang YanQing <udknight@gmail.com> wrote:
>
> Current we can only enable lib80211 by enable a driver
> in tree use it which will select it, but some out tree's
> drivers also use it, so I think it has sense to make lib80211
> can be enabled independently.

Just as a bit of explanation for Johannes' NACK:

1. The only reason lib80211 still exists is because a couple of
in-tree drivers still use it. If this weren't the case, the code would
have been removed a long time ago as it's been completely replaced by
mac80211 and cfg80211. All modern drivers _must_ use mac80211 or
cfg80211 without exception.
2. In general, there is no official in-kernel support for
out-of-kernel drivers, regardless of quality, status or importance.
3. I believe that the in-tree brcmsmac driver already supports the
Broadcom card you reference.

Thanks,

--
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
.Plan: http://sites.google.com/site/juliancalaby/
