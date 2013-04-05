From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH] lib80211: make lib80211 can be enabled independently
Date: Thu, 04 Apr 2013 21:01:59 -0700
Message-ID: <515E4CB7.6020405@infradead.org>
References: <20130404160130.GA2577@udknight> <CAGRGNgXj7mSF0Fgyjek4Xcc34N26WHtt4HMmHk7DOopaEPrYFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wang YanQing <udknight@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Julian Calaby <julian.calaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:53231 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab3DEEBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 00:01:55 -0400
In-Reply-To: <CAGRGNgXj7mSF0Fgyjek4Xcc34N26WHtt4HMmHk7DOopaEPrYFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/04/13 16:51, Julian Calaby wrote:
> Hi Wang,
> 
> On Fri, Apr 5, 2013 at 3:01 AM, Wang YanQing <udknight@gmail.com> wrote:
>>
>> Current we can only enable lib80211 by enable a driver
>> in tree use it which will select it, but some out tree's
>> drivers also use it, so I think it has sense to make lib80211
>> can be enabled independently.
> 
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


3b.  If 3. is not correct, someone should endeavor to merge this
out-of-tree driver into the kernel tree.


-- 
~Randy
