From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Understanding lock contention in __udp4_lib_mcast_deliver
Date: Thu, 27 Jun 2013 13:46:58 -0700
Message-ID: <51CCA4C2.7050301@hp.com>
References: <20130627192218.GA5936@sbohrermbp13-local.rgmadvisors.com> <51CC996F.3020507@hp.com> <20130627202008.GB5936@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:39896 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773Ab3F0UrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 16:47:00 -0400
In-Reply-To: <20130627202008.GB5936@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/27/2013 01:20 PM, Shawn Bohrer wrote:
> On Thu, Jun 27, 2013 at 12:58:39PM -0700, Rick Jones wrote:
>> Are there other processes showing _raw_spin_lock time?  It may be
>> more clear to add a --sort symbol,dso or some such to your perf
>> report command.  Because what you show there suggests less than 1%
>> of the active cycles are in _raw_spin_lock.
>
> You think I'm wasting time going after small potatoes huh?

Perhaps.  I also find it difficult to see the potatoes' (symbols') big 
picture in perf's default sorting :)

> On a normal system it looks like it is about .12% total which is
> indeed small but my thinking was that I should be able to make that
> go to 0 easily by ensuring we use unique ports and only have one
> socket per multicast addr:port.  Now that I've failed at making it go
> to 0 I would mostly like to understand what part of my thinking was
> flawed. Or perhaps I can make it go to zero if I do ...

How do you know that time is actually contention and not simply acquire 
and release overhead?

rick jones
