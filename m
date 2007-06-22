From: Erik Slagter <erik@slagter.name>
Subject: Re: Linksys Gigabit USB2.0 adapter (asix) regression
Date: Fri, 22 Jun 2007 21:08:10 +0200
Message-ID: <467C1E1A.1010007@slagter.name>
References: <467915D9.3030900@slagter.name> <1182523020.4938.20.camel@dhollis-lnx.sunera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Hollis <dhollis@davehollis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from erik-slagter.demon.nl ([83.160.41.216]:37491 "EHLO
	artemis.slagter.name" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760191AbXFVTIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 15:08:12 -0400
In-Reply-To: <1182523020.4938.20.camel@dhollis-lnx.sunera.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Hollis wrote:

>> To rule out the possibility of the nic being defective, I connected the
>> USB nic to a windows computer. There it works, although the ethernet
>> connection is a bit flaky (just like it seems...).
>>
>> Then I did a diff on the respective kernel sources of 2.6.20.3 and
>> 2.6.22-rc2 (asix.c and usbnet.c), I found a few changes, but they do not
>> seem to be related to my problem.
>>
>> I am the and of my repertoire here, can anyone please do some
>> suggestions for further testing or even better, fix it ;-)
> 
> You wouldn't happen to know what PHY that device is using?  The AX88178
> (Gigabit USB Ethernet) support in the driver currently only supports the
> Marvell PHY, which is the only one I've actually encountered to-date.
> If you can rebuild the driver from your kernel sources but with DEBUG
> enabled (uncomment it at the top of asix.c)

No problem, I will do it on sunday. No need to build the driver
out-of-tree btw.

> After you build the module, load it with insmod ./asix.ko, plug in your
> device and send me the dmesg output.  I'm particularly interested in the
> PHYID=0x12345678 line.  That will tell me what PHY chip is being used in
> that device and if I need to add support for it.

Will do. Thanks!

