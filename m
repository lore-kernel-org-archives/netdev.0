From: Bernhard Schmidt <berni@birkenwald.de>
Subject: Re: [Bugme-new] [Bug 12877] New: tg3: eth0 transit timed out,	resetting
 -> dead NIC
Date: Mon, 13 Apr 2009 23:54:40 +0200
Message-ID: <49E3B4A0.8040009@birkenwald.de>
References: <bug-12877-10286@http.bugzilla.kernel.org/> <20090315143214.90c71fb7.akpm@linux-foundation.org> <1237238601.8839.85.camel@HP1> <49C01F7F.9030306@birkenwald.de> <20090319165842.GA10819@xw6200.broadcom.net> <20090322132121.GA7871@pest> <20090331162617.GB15533@xw6200.broadcom.net> <20090331221621.GA1324@schleppi.birkenwald.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.svr02.mucip.net ([83.170.6.69]:34712 "EHLO
	mailout.mucip.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753718AbZDMVys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 17:54:48 -0400
In-Reply-To: <20090331221621.GA1324@schleppi.birkenwald.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Matt,

>>> I'm now switching to eth1.
>> Bernhard, any word on what happened?
> 
> So far so good. In the last week my watchdog (cannot reach the default
> gateway) triggered once, but since there were no "PCI Memory Mapped IO
> Disabled!!!!" messages in the logfile I assume that was a real network
> problem. Since the box ran fine for months initially and the first two
> occurances of this issue were two weeks apart I cannot say for sure, but
> it definitely feels better than the "once in two days" in the end.

No crashes in the last two weeks.

Do you have any further suggestions how to debug this or should we 
accept that portsharing doesn't work very well? This is the second 
problem we can directly attribute to the sharing with the iLO (the first 
one being the "no IPv6 unless the port is in promiscous mode", we had a 
thread about this here on netdev a few months ago).

Bernhard
