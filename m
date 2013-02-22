From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Problem with Reaktek 8168
Date: Sat, 23 Feb 2013 00:07:57 +0100
Message-ID: <20130222230757.GA4248@electric-eye.fr.zoreil.com>
References: <5124B909.4080907@online.de> <20130220231122.GA22163@electric-eye.fr.zoreil.com> <51256EC7.90505@online.de> <20130221224543.GA11240@electric-eye.fr.zoreil.com> <512786D7.6090003@online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ralf Friedl <Ralf.Friedl@online.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:36097 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755438Ab3BVXju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 18:39:50 -0500
Content-Disposition: inline
In-Reply-To: <512786D7.6090003@online.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ralf Friedl <Ralf.Friedl@online.de> :
[...]
> I have one warning in the syslog, but I hope it is not serious.
> WARNING: at net/sched/sch_generic.c:254 dev_watchdog+0x239/0x250()
> NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
[snip]

It's the usual transmit timeout watchdog. A transient loss of network
traffic should be noticable when it triggers. You may live with it as
long as it does not happen much but it means that something does not
work correctly.

-- 
Ueimor
