From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 11144] New: dhcp doesn't work with iwl4965
Date: Tue, 22 Jul 2008 12:52:20 +0200
Message-ID: <4885BBE4.9030102@trash.net>
References: <bug-11144-10286@http.bugzilla.kernel.org/> <20080722034850.dbbc5566.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: francois.valenduc@tvcablenet.be, bugme-daemon@bugzilla.kernel.org,
	linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58409 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753160AbYGVKwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 06:52:23 -0400
In-Reply-To: <20080722034850.dbbc5566.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Tue, 22 Jul 2008 03:21:33 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=11144
>>
>>            Summary: dhcp doesn't work with iwl4965

>> Latest working kernel version: 2.6.26-git6
>> Earliest failing kernel version: 2.6.26-git7
> 
> A very fresh regression.
> 
>> Distribution: Gentoo
>> Hardware Environment: Packard Bell MB86, iwl4965
>> Software Environment: dhcpcd
>> Problem Description: 
>> I can't get an IP address via DHCP with my wireless connection. I have an Intel
>> Wireless 4965 card and I use WPA personal with AES encryption. After a
>> git-bisect run, it seems the first bad commit is the following:
>>
>> commit 175f9c1bba9b825d22b142d183c9e175488b260c
>> Author: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
>> Date:   Sun Jul 20 00:08:47 2008 -0700
>>
>>     net_sched: Add size table for qdiscs
>>
>>     Add size table functions for qdiscs and calculate packet size in
>>     qdisc_enqueue().
>>

This implies you're running shaping on your WLAN device. Please
post the rules you're using.


