From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Resource usages in Linux drivers
Date: Fri, 24 Apr 2015 01:19:17 +0200
Message-ID: <20150423231917.GA16450@electric-eye.fr.zoreil.com>
References: <5538950F.3040405@163.com>
 <5538B938.9060607@cogentembedded.com>
 <5538BB61.30907@163.com>
 <5538C4A3.6080302@163.com>
 <5538CB50.3010601@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jia-Ju Bai <baijiaju1990@163.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	stephen@networkplumber.org, Neil Horman <nhorman@tuxdriver.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48599 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932841AbbDWXUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 19:20:12 -0400
Content-Disposition: inline
In-Reply-To: <5538CB50.3010601@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> :
> On 4/23/2015 1:08 PM, Jia-Ju Bai wrote:
[...]
> >I also find many drivers do not use these managed APIs, especially in ethernet
> >card drivers (like e100, r8169). Is it possible to change them?
> 
>    Patches welcome. :-)

I respectfully disagree.

If someone believes basic resouce management to be too hard or error-prone
to handle, he should imvho seriously rise the bar and reconsider the way
he wants to contribute to the kernel.

I may hope he who reads e100.c to think about DMA api, bql or rx ring
holes avoidance to quote a few ones. Managed API ? Mildly...

-- 
Ueimor
