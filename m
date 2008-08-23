From: Guo-Fu Tseng <cooldavid@cooldavid.org>
Subject: Re: [PATCH netdev-2.6] jme: JMicron Gigabit Ethernet Driver
Date: Sun, 24 Aug 2008 00:04:50 +0800
Message-ID: <48B03522.9020604@cooldavid.org>
References: <48AFA8A8.6070604@cooldavid.org> <48AFB137.9020506@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ethan <ethanhsiao@jmicron.com>, akeemting <akeem@jmicron.com>,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 220-133-139-86.HINET-IP.hinet.net ([220.133.139.86]:59315 "EHLO
	cooldavid.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751597AbYHWQE5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Aug 2008 12:04:57 -0400
In-Reply-To: <48AFB137.9020506@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Guo-Fu Tseng wrote:
>> Hi, Jeff:
>>
>> Here is the full patch of JMicron Gigabit Ethernet driver.
>> Supporting JMC250, and JMC260.
>>
>> I'm new in this submitting system, I've tried hard not to done silly 
>> errors.
>> Comments, and corrections are welcome from anyone. Thank you for 
>> reviewing it.
>>
>> The patch is also available at:
>> http://cooldavid.org/download/jme.netdev-2.6.20080823.patch
>>
>> Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
>
> Very nice and clean and feature-complete!  Comments:
>
Thank you! You are so kind. :-)
> * the definition of jwrite32() and jread32():  writel() and readl() 
> are defined in terms of the little-endian PCI bus, and therefore 
> automatically handle byteswapping (or not) as defined by the platform 
> API.
>
> You should be able to just remove those le32_to_cpu() and the reverse, 
> to obtain proper behavior.
>
Removed it.
> * The atomic values rx_cleaning and tx_cleaning look problematic and 
> potentially racy, though I admit not having completely evaluated its 
> usage.
>
Re-writing it.
> * we prefer not to add custom ioctls, but rather add functionality to 
> ethtool.  in particular, JMESPIIOCTL does not appear to have any 
> security checks, and is a potential security hole that permits an 
> unpriveleged user direct access to hardware
>

Should I add privilege check, or should(could?) I send a patch that add 
ethtool interface for flash(For storing PXE code) read/write?


Thank you for super-fast reply.

