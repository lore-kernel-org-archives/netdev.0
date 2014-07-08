From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-next 2014-07-03
Date: Tue, 08 Jul 2014 14:13:28 -0700 (PDT)
Message-ID: <20140708.141328.1589777085621867948.davem@davemloft.net>
References: <20140703191211.GB13303@tuxdriver.com>
	<20140703204141.GD13303@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140703204141.GD13303@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Thu, 3 Jul 2014 16:41:42 -0400

> On Thu, Jul 03, 2014 at 03:12:11PM -0400, John W. Linville wrote:
>> Dave,
>> 
>> Please pull this first batch of wireless updates intended for the
>> 3.17 stream...
>> 
>> For the mac80211 bits, Johannes says:
>> 
>> "The biggest thing here is probably Arik's TDLS rework, beyond that we
>> have smaller improvements and features like David's scanning IE thing,
>> Luca's queue work, some CSA work, etc. Also your PID rate control
>> removal, of course."
>> 
>> For the iwlwifi bits, Emmanuel says:
>> 
>> "I have here a fix from Eliad for scheduled scan: it fixes a firmware
>> assertion. Arik reverts a patch I made that didn't take into account
>> that 3160 doesn't have UAPSD and hence, we can't assume that all
>> newer firmwares support the feature. Here too, the visible effect
>> is a firmware assertion. Along with that, we have a few fixes and
>> additions to the device list."
> 
> I copied the wrong text.  It should have read as follows:
> 
> "I have here a whole bunch of various things. Andy contributes
> better debug prints for dvm specific flows and a module parameter to
> completely disable power save for dvm. Andrei is sharing the premises
> of his work on CSA - more to come. Eran and Liad keep on working
> on the new devices. I have the regular amount of BT Coex stuff and
> I continue to work on the firmware error report system adding more
> debug capabilities. More to come on that subject too."
> 
> Sorry for the confusion!

I fixed the text up and pulled, thanks John.
