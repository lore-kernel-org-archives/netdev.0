From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: wireless extensions vs. 64-bit architectures
Date: Fri, 9 Mar 2007 13:35:31 -0800
Message-ID: <20070309213531.GA28070@bougret.hpl.hp.com>
References: <20070306171316.GA19669@bougret.hpl.hp.com> <200703061943.07350.mb@bu3sch.de> <20070307020310.GA20466@bougret.hpl.hp.com> <1173364747.14001.7.camel@johannes.berg> <20070308184954.GA24485@bougret.hpl.hp.com> <1173382042.3248.63.camel@johannes.berg> <20070308193412.GG23040@devicescape.com> <1173382802.3248.68.camel@johannes.berg> <20070308221128.GA24884@bougret.hpl.hp.com> <1173393326.3831.21.camel@johannes.berg>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jouni Malinen <jkm@devicescape.com>, Michael Buesch <mb@bu3sch.de>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Jeff Garzik <jgarzik@pobox.com>, Dan Williams <dcbw@redhat.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:59169 "EHLO
	gundega.hpl.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767547AbXCIVhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 16:37:09 -0500
Content-Disposition: inline
In-Reply-To: <1173393326.3831.21.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 08, 2007 at 11:35:26PM +0100, Johannes Berg wrote:
> On Thu, 2007-03-08 at 14:11 -0800, Jean Tourrilhes wrote:
> 
> > 	First possiblity, we could stick with this band-aid
> > permanently.
> 
> It sucks for various reasons, one for example being that I don't even
> understand your recognition code but all userspace programs that use
> wext will have to include such code!

	It's not as bad as it look like. All userspace programs
nowadays use either the iwlib or wpa_supplicant. For example,
NetworkManager gets its stuff through wpa_supplicant, and kdenetwork
uses iwlib. So, in essence, there is only two places to fix.
	Which is why I would like to hear from Jouni.

	By the way, I've just released version 29.pre16 which has a
better band aid. It fixes bugs of the previous version and is more
forward compatible (i.e. it's compatible with option 2).

	Have fun...

	Jean
