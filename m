From: Maarten Lankhorst <m.b.lankhorst@gmail.com>
Subject: Re: [PATCH] Remove CONFIG_NET_WIRELESS
Date: Mon, 15 Jan 2007 13:55:45 +0100
Message-ID: <45AB79D1.2070002@gmail.com>
References: <45A91414.40107@gmail.com> <1168860268.3344.0.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>, mb@bu3sch.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailserver.astro.rug.nl ([129.125.6.166]:39274 "EHLO
	mailserver.astro.rug.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932312AbXAON2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 08:28:35 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1168860268.3344.0.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg schreef:
> On Sat, 2007-01-13 at 18:17 +0100, Maarten Lankhorst wrote:
>   
>> Remove CONFIG_NET_WIRELESS
>> Nothing uses this, and it breaks the kernel build if a wireless device is used with a unsupported type of bus.
>> Verified this with a grep.
>>     
>
> I don't really care about the symbol and I'm in favour of removing it if
> it is useless, but I don't understand the rationale. How does enabling
> this cause anything to fail?
>
> johannes
>   
Enabling this doesn't cause anything to fail, but my wireless router
doesn't have a pci bus, but instead a native SSB, so CONFIG_NET_WIRELESS
isn't selected. This in turn causes wext-common.o to not be built, so I
get missing symbols and a build breakage. That's why I made
wext-common.o depend on CONFIG_WIRELESS_EXT instead of
CONFIG_NET_WIRELESS. Since nothing else uses CONFIG_NET_WIRELESS I
decided to kill that symbol.

maarten
