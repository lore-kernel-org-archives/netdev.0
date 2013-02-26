From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [RFC/RFT 00/27] Updates for the rtlwifi family of drivers
Date: Mon, 25 Feb 2013 21:04:42 -0600
Message-ID: <512C264A.3000104@lwfinger.net>
References: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net> <1361845357.2023.7.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, jcheung@suse.com, machen@suse.com,
	mmarek@suse.cz
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:49678 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755387Ab3BZDEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 22:04:45 -0500
In-Reply-To: <1361845357.2023.7.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25/2013 08:22 PM, Joe Perches wrote:
> On Mon, 2013-02-25 at 18:13 -0600, Larry Finger wrote:
>> This set of patches upgrades drivers rtlwifi, rtl8192c, rtl8192ce, rtl8192se,
>> and rtl8723ae to the state of the vendor driver issued on 2013.02.07. In
>> addition, a new driver for the RTL8188EE chip is added to the kernel.
>>
>> Note: These patches do not upgrade rtl8192de. Those changes will be sent
>> later.
>
> rtl8188e isn't very kernel stylish.
> Looking at it briefly, in fact it's kind of ugly.
>
> Could/should it go into staging?

It is uglier than I had hoped. I was not quite ready to push it yet, but I got 
some pressure from outside, non-Realtek, sources that a kernel version was 
needed. They will, in fact, start their integration from the RFC/RFT version.

The main problem with having it in staging is that we will either have to 
include headers from drivers/net/wireless/rtlwifi/, or duplicate them in the 
drivers/staging/rtl8188ee/ directory where keeping them compatible will be a 
hassle. Neither solution sounds optimum to me.

Larry
