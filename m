From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: [PATCH] lib80211: make lib80211 can be enabled
 independently
Date: Fri, 5 Apr 2013 09:25:15 +0200
Message-ID: <515E7C5B.2000408@broadcom.com>
References: <20130404160130.GA2577@udknight>
 <CAGRGNgXj7mSF0Fgyjek4Xcc34N26WHtt4HMmHk7DOopaEPrYFw@mail.gmail.com>
 <515E4CB7.6020405@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Julian Calaby" <julian.calaby@gmail.com>,
	"Wang YanQing" <udknight@gmail.com>,
	"Johannes Berg" <johannes@sipsolutions.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Randy Dunlap" <rdunlap@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <515E4CB7.6020405@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/05/2013 06:01 AM, Randy Dunlap wrote:
> On 04/04/13 16:51, Julian Calaby wrote:
>> Hi Wang,
>>
>> On Fri, Apr 5, 2013 at 3:01 AM, Wang YanQing <udknight@gmail.com> wrote:
>>>
>>> Current we can only enable lib80211 by enable a driver
>>> in tree use it which will select it, but some out tree's
>>> drivers also use it, so I think it has sense to make lib80211
>>> can be enabled independently.
>>
>> Just as a bit of explanation for Johannes' NACK:
>>
>> 1. The only reason lib80211 still exists is because a couple of
>> in-tree drivers still use it. If this weren't the case, the code would
>> have been removed a long time ago as it's been completely replaced by
>> mac80211 and cfg80211. All modern drivers _must_ use mac80211 or
>> cfg80211 without exception.
>> 2. In general, there is no official in-kernel support for
>> out-of-kernel drivers, regardless of quality, status or importance.
>> 3. I believe that the in-tree brcmsmac driver already supports the
>> Broadcom card you reference.
>
>
> 3b.  If 3. is not correct, someone should endeavor to merge this
> out-of-tree driver into the kernel tree.

Actually, it is correct and brcmsmac and the out-of-tree wl driver are 
coming from the same code base although you should not compare the two 
these days.

Gr. AvS
