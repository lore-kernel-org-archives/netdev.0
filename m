From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: Feature request: "inverted" ping -a (beep on failure)
Date: Fri, 15 Apr 2011 23:10:30 +0300
Message-ID: <1e0eef572c2d10257fe4894f0b3e9c18@visp.net.lb>
References: <201104152135.33171@tux.boltz.de.vu>
 <20110415124937.6e746646.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christian Boltz <netdev-vger-kernel.org@cboltz.de>,
	<netdev@vger.kernel.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rev-153-13.globalproof.net ([194.146.153.13]:54825 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754920Ab1DOUVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 16:21:07 -0400
In-Reply-To: <20110415124937.6e746646.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On Fri, 15 Apr 2011 12:49:37 -0700, Randy Dunlap wrote:
> On Fri, 15 Apr 2011 21:35:32 +0200 Christian Boltz wrote:
>
>> Hello,
>>
>> ping -a (beep on ping success) is a quite useful command, but it can 
>> be
>> annoying.
>>
>> I'd like to have the exact opposite of it: beep when pinging fails.
>>
>> I understand that this is slightly difficult because "ping success" 
>> is
>> easier to detect (incoming package) than "ping failure" (no incoming
>> package or firewall reject) - my proposal is to have a timeout for 
>> every
>> package (if no reply package comes in) and beep if no reply is seen
>> after the timeout is over.
>>
>> For the timeout, the -W option could be used. The default timeout 
>> seems
>> to be 10 seconds, which is OK.
>>
>> Usecase / why this would be useful for me:
>> Basically for server monitoring. The exact usecase is that I have 
>> rented
>> a "root server" and asked the hoster to exchange a broken harddisk.
>> With the "inverted" ping -a, it would be easy to notice when they 
>> switch
>> off the server to replace the disk.
>>
>> Please consider this feature for the next version of ping ;-)
>>
>>
>> (The iputils homepage does not list any bugtracker or similar, 
>> therefore
>> I'm asking here.)
>
> Couldn't you look for exit code (status) 1 and then do a bell/beep
> (or play a sound file :)?
>
> Or do you want ping to beep and then continue running?
>
 I wrote my own tool and call it ping watchdog (i so ideas about ping 
 watchdog in other projects, just improved it a little) :-)
 Probably it can be useful here, it can run script if ping fail more 
 than N packets... it is a bit undocumented and cryptic, but i can 
 improve it.

 http://code.google.com/p/sysadmin-tools/source/browse/trunk/pingwdog/pingwdog.c

