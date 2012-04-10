From: Ben Greear <greearb@candelatech.com>
Subject: Re: Please revert removal of /sys/class/net/*/features
Date: Tue, 10 Apr 2012 11:32:23 -0700
Message-ID: <4F847CB7.3040603@candelatech.com>
References: <20120410110851.5690739c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:39588 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757643Ab2DJSc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 14:32:28 -0400
In-Reply-To: <20120410110851.5690739c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/2012 11:08 AM, Stephen Hemminger wrote:
> This commit needs to be reverted. It removed an available sysfs file, and sysfs
> files are part of the ABI. It caused a bug in our current release of Vyatta because
> the shell script was using the sysfs file to see if VLAN was supported on a device.

It's a hack, but you can also make some vlan IOCTL calls to a device
to probe if it's VLAN or not..thats what I've been doing for the last
decade or so :)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
