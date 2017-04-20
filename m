From: Stefan Agner <stefan-XLVq0VzYD2Y@public.gmane.org>
Subject: Re: [PATCH] nl80211: fix enumeration type
Date: Thu, 20 Apr 2017 07:21:40 -0700
Message-ID: <cbdee27002a2f285221bb83af835430a@agner.ch>
References: <20170420065513.1930-1-stefan@agner.ch>
 <1492672926.3109.5.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1492672926.3109.5.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2017-04-20 00:22, Johannes Berg wrote:
> On Wed, 2017-04-19 at 23:55 -0700, Stefan Agner wrote:
>> Use type enum nl80211_rate_info for bitrate information. This fixes
>> a warning when compiling with clang:
>>   warning: implicit conversion from enumeration type 'enum
>> nl80211_rate_info'
>>   to different enumeration type 'enum nl80211_attrs'
> 
> I'm pretty sure I just applied exactly these two patches very recently.
> 
> What made *two* people suddenly see this?

There has been renewed work on compiling Linux using clang... Sorry for
the clash.

--
Stefan
