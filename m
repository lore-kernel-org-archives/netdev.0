From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: network interface *name* alias support?
Date: Fri, 23 May 2008 18:31:03 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0805231817100.25193@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, dwmw2@infradead.org
To: johnathan@jonmasters.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:58401 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111AbYEWQbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2008 12:31:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jon Masters wrote:
>>On Fri, 2008-05-23 at 14:07 +0100, David Woodhouse wrote:
>> On Wed, 2008-05-21 at 18:47 -0400, Jon Masters wrote:
>>> 
>>> I would like to add support for network interface name aliases to
>>> the kernel. For example, rather than simply "eth0", one might
>>> have:
>>> 
>>> eth0 -> eth_slot_0_0
>>> 
>>> And use either name for device configuration, etc. This should be
>>> pretty easy, but I would like some comments - in particular, has
>>> this been done already and I'm missing something?
>> 
>> Why do you need a given interface to have more than one name? Why
>> not just assign names according to whatever criteria you care
>> about? That's entirely a udev problem, surely?
>
>Well, for various reasons, we have folks who want to always retain
>the existing "legacy" naming to "avoid confusion". Yeah, personally
>I don't really think it matters...but apparently it does, so I'm
>happy to oblige and have udev set an alias according to physical
>slot position aswell.

It is up to the user what name an interface gets. As such, you can 
encode all information you need into it, limited only by the 
maximum name length. Where is the problem?

If one personally cannot associate ethX with a hardware port, you can 
rename it to be more meaningful. I have done that with server boxen,
where things like igb0 and igb1 denoted the Intel E1000 in the PCI slot, 
iet0 the on-board Intel E100, and bcm0/bcm1 the two on-board (it's a 
Tyan S2892) Broadcom ethernets; and all is well.

It is a bit of a pity that Linux by default calls all its Ethernet 
devices just "eth", quite unlike BSD/Solaris. Only very few (Ethernet) 
drivers use non-ethX naming, namely raX for Ralink before it was merged, 
wlanX for ndiswrapper it seems, and athX for madwifi.
