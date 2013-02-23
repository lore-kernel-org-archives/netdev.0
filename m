From: Ralf Friedl <Ralf.Friedl@online.de>
Subject: Re: Problem with Reaktek 8168
Date: Sat, 23 Feb 2013 12:10:09 +0100
Message-ID: <5128A391.2000608@online.de>
References: <5124B909.4080907@online.de> <20130220231122.GA22163@electric-eye.fr.zoreil.com> <51256EC7.90505@online.de> <20130221224543.GA11240@electric-eye.fr.zoreil.com> <512786D7.6090003@online.de> <20130222230757.GA4248@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:56713 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757040Ab3BWLKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2013 06:10:03 -0500
In-Reply-To: <20130222230757.GA4248@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu:
> Ralf Friedl <Ralf.Friedl@online.de> :
> [...]
>   
>> I have one warning in the syslog, but I hope it is not serious.
>> WARNING: at net/sched/sch_generic.c:254 dev_watchdog+0x239/0x250()
>> NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
>>     
> [snip]
>
> It's the usual transmit timeout watchdog. A transient loss of network
> traffic should be noticable when it triggers. You may live with it as
> long as it does not happen much but it means that something does not
> work correctly.
I had this happen once for about 300GB of transfer data, so I can live 
with this.
But if you have an idea what it might be, I can run some tests for you.

Ralf
