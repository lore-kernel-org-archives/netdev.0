From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] softmac: Fix handling of authentication failure
Date: Fri, 02 Jun 2006 09:55:48 -0500
Message-ID: <44805174.9000503@lwfinger.net>
References: <20060601143722.D0B2C89CF47@zog.reactivated.net> <447FA5B5.8020707@lwfinger.net> <44800E74.9070605@gentoo.org> <20060602120439.GA14289@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:64737 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751302AbWFBOzw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jun 2006 10:55:52 -0400
To: Daniel Drake <dsd@gentoo.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, johannes@sipsolutions.net
In-Reply-To: <20060602120439.GA14289@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> On Fri, Jun 02, 2006 at 11:09:56AM +0100, Daniel Drake wrote:
>   
>> Larry Finger wrote:
>>     
>>> This statement fails to compile on my system using Linus' tree, because 
>>> ieee80211softmac_disassoc needs a second argument - the reason. It seems 
>>> as if WLAN_REASON_PREV_AUTH_NOT_VALID would be appropriate.
>>>       
>> Thanks for pointing that out. This patch depends on a patch titled 
>> "softmac: deauthentication implies deassociation" which is apparently 
>> not present in Linus' tree.
>>     
>
> That patch is in the upstream branch (also available in the master
> branch) of wireless-2.6, which is probably what anyone doing wireless
> patches should(*) be using.
>
> The approved release process only allows for non-bugfix patches
> in the first two weeks after a Linus blesses a new kernel release.
> After that only bugfixes are allowed, with non-bugfix patches getting
> queued for the next merge window.  The upstream branch represents
> that queue of patches.
>
> Hth!
>
> John
>
> (*) The exception being those workign on Devicescape-related patches,
> who should be working off the master branch of wireless-dev.
>   
Normally I use the master branch of wireless-2.6; however that code has 
something in it that kills interrupts from my bcm4306 card, but I 
haven't had time to chase down that problem. A second difficulty is that 
my Linksys WRT54G V1 died and the only replacement I could find on short 
notice was a V5 model, which is truly an abomination using VXWorks, not 
Linux. When the AP changed, my working system of bcm43xx-softmac with 
WPA authentication now refuses to authenticate, and I have to use a 
wired connection. Accordingly, I try every softmac patch that might 
solve my problem - thus I applied Daniels's patch to Linus's tree.

Larry


