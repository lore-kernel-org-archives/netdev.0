From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: iwl rfkill suddenly dropped to hard block
Date: Wed, 15 Dec 2010 22:23:32 -0600
Message-ID: <4D099444.5040703@lwfinger.net>
References: <20101215195651.GA18545@ioremap.net> <20101215201126.GG2377@tuxdriver.com> <20101216032247.GA7345@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	wey-yi.w.guy@intel.com
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:44033 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750989Ab0LPEXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 23:23:39 -0500
In-Reply-To: <20101216032247.GA7345@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/15/2010 09:22 PM, Evgeniy Polyakov wrote:
> On Wed, Dec 15, 2010 at 03:11:27PM -0500, John W. Linville (linville@tuxdriver.com) wrote:
>> Cc'ing linux-wireless and Wey-Yi...
>>
>> To be honest, nearly every report of "suddenly my rfkill is stuck
>> on" is because the laptop has multiple rfkill keys, usually with
>> one of them a slider along the edge of the case.  In particular,
>> Thinkpads have such switches.  The slider gets accidently engaged
>> (possibly while the laptop is being transported or somesuch) and
>> suddenly wireless stops working.
>>
>> Please check for the above.  If you are sure that isn't the case, then
>> please try to determine the last working kernel and do a bisection --
>> hopefully you don't have to go all the way back to 2.6.33!
>
> I'm pretty sure it would be that simple if there was such a slider.
>
> There is no way I can bisect this problem since, first, i915 does not
> work anywhere after 2.6.34 upto current git tree, and second, because
> wifi perfectly well worked two days ago with this kernel, and now there
> are no good and bad kernels, only bad ones.
>
> Turning on dell_wmi brings 2 more rfkill classes, which are both
> hard and soft blocked. Both can not be unblocked (even soft unblock),
> although reported case can be soft unblocked (hard block status
> obviously does not change). Actually by default it is soft unblocked,
> other two (another wifi switch and bluetooth) are both hard and soft
> blocked.
>
> I would imagine this is just related to some dellish crap, but I saw a
> number of exactly the same cases in the web including linux-kernel mail
> lists in the past and also without 'slider on the back' case.

I doubt that it is Dell related, if that is what "dellish" means.

I have had some success in clearing this problem by unloading and reloading the 
wireless driver. I had the problem on one box that has no rfkill switch and an 
802.11b card that uses b43legacy.

Larry
