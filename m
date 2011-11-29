From: Markus Feldmann <feldmann_markus@gmx.de>
Subject: Re: Daughterboard Jetway JAD3RTLANG with three RTL-8110SC/8169SC
 Gigabit Ethernet is curious
Date: Tue, 29 Nov 2011 15:16:38 +0100
Message-ID: <4ED4E946.40209@gmx.de>
References: <jb0d7u$bbb$1@dough.gmane.org> <201111291012.25426.carsten@wolffcarsten.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:57583 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754760Ab1K2OQ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Nov 2011 09:16:58 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1RVOUQ-0007Ie-Tc
	for netdev@vger.kernel.org; Tue, 29 Nov 2011 15:16:54 +0100
Received: from dslb-092-076-227-186.pools.arcor-ip.net ([92.76.227.186])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 15:16:54 +0100
Received: from feldmann_markus by dslb-092-076-227-186.pools.arcor-ip.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 15:16:54 +0100
In-Reply-To: <201111291012.25426.carsten@wolffcarsten.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 29.11.2011 10:12, schrieb Carsten Wolff:
> Hi Markus,
>
> On Monday 28 November 2011, Markus Feldmann wrote:
>> Hi All,
>>
>> i have a mini-ITX PC (Motherboard Jetway JNF92-270-LF), whit 3 ethernet
>> devices (RTL-8110SC/8169SC Gigabit Ethernet) on one additional
>> daughterboard (Jetway JAD3RTLANG).
>>
>> Here is my<hwinfo --netcard>  output:
>> http://pastebin.com/raw.php?i=Khy1NX61
>>
>> and dmesg:
>> http://pastebin.com/raw.php?i=Ziq1mizy
>>
>> I am using this mini-ITX PC as server/router with a debian
>> squeeze/stable system.
>>
>> My problem is that only one of this three ethernet devices (from the
>> daughterboard not the internal one from motherboard) at once is working
>> correctly. Sometimes i have only one client to my server connected, but
>> only one specific ehernet port is working (mostly the physically upper
>> one). I didnt found any regularity yet.
> I guess "not working" means "link detected: no" in ethtool?
>
>> Any hints? is there a specific person whom i schould contact?
> I had a similar (the same?) problems with this hardware about 2 years ago. My
> "solution" was to install windows + drivers, then throw windows away and
> install debian. After that, I had no more problems with those NICs. Since
> then, there have been some patches to the initialization code for these RTL
> Linux drivers, but maybe the windows driver installs newer firmware, too,
> which may be required for that particular product.
>
> Carsten
Hi,

You mean the latest Linux kernel was patched for a better 
initialization? At the moment i am using the kernel 3.0.8. As i 
understood the firmware must be loaded at every power on.

regards Markus
