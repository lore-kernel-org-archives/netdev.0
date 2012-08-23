From: Ying Xue <ying.xue@windriver.com>
Subject: Re: TIPC handling of ethernet mac address change
Date: Thu, 23 Aug 2012 14:56:23 +0800
Message-ID: <5035D417.3010402@windriver.com>
References: <5034FC88.8030403@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Allan Stephens <allan.stephens@windriver.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	netdev <netdev@vger.kernel.org>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:47481 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261Ab2HWG4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 02:56:35 -0400
In-Reply-To: <5034FC88.8030403@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Chris,

You are right.

Currently TIPC does not handle the change of mac address.
So I will submit a related patch to fix the issue to net-next tree.

Thanks for your report.

Regards,
Ying


Chris Friesen wrote:
> Hi,
>
> I'm pretty new to tipc so pardon me if I use the wrong terminology. :)
>
> I'm using TIPC 1.7.7 and bonding.  I'm seeing some strange behaviour 
> when the bond MAC address changes--the tipc LINK_CONFIG messages still 
> contain the old MAC address embedded in them.  This causes the other 
> end to send back to us on the wrong MAC and the packets get dropped.
>
> I see recv_notification() has a case for NETDEV_CHANGEADDR so it looks 
> like MAC address change was intended to be handled, but I'm not 
> entirely clear on where the MAC address is supposed to be changed.
>
> Any assistance on debugging/patching this would be appreciated.
>
> Chris
>
>
