From: Naohiro Ooiwa <nooiwa@miraclelinux.com>
Subject: Re: [PATCH] e1000: the power down when running ifdown command
Date: Thu, 05 Nov 2009 23:58:21 +0900
Message-ID: <4AF2E80D.2060808@miraclelinux.com>
References: <4AEC05E8.40600@miraclelinux.com>	<20091031105838.0d4b59a2@nehalam>	<4AEE35D2.4000503@miraclelinux.com>	<4AF1562F.8010401@miraclelinux.com> <20091104080846.5bf4d225@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	davem@davemloft.net, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, svaidy@linux.vnet.ibm.com,
	e1000-devel@lists.sourceforge.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw.miraclelinux.com ([122.216.84.157]:43249 "EHLO
	mailgw.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758121AbZKEO6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 09:58:13 -0500
In-Reply-To: <20091104080846.5bf4d225@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Wed, 04 Nov 2009 19:23:43 +0900
> Naohiro Ooiwa <nooiwa@miraclelinux.com> wrote:
> 
>> Naohiro Ooiwa wrote:
>>> Stephen Hemminger wrote:
>>>> On Sat, 31 Oct 2009 18:39:52 +0900
>>>> Naohiro Ooiwa <nooiwa@miraclelinux.com> wrote:
>>>>
>>>> Does this work with Wake On Lan? 
>>> Yes, it works WOL.
>> Sorry, I made a mistake.
>> The WOL doesn't work when my patch applied to kernel.
>> I wasn't myself.
>>
>> I consider the WOL and I will resent the patch.
>> Thank you for your point.
>>
>>
>> thanks,
>> Naohiro Ooiwa
> 
> 
> Good, thank you for checking. I like the idea of powering down the
> PHY. Some of the drivers have shutdown hooks to power PHY back on
> during shutdown to enable WOL.
> 

Thank you so much for your infomation.
Oh, The shutdown hooks is useful.


Thanks.
Naohiro Ooiwa
