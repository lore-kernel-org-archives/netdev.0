From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: softmac mtu
Date: Sat, 23 Sep 2006 16:59:48 -0500
Message-ID: <4515AE54.4040403@lwfinger.net>
References: <ef3s4u$or5$3@sea.gmane.org> <4515A9BF.90709@lwfinger.net> <20060923.144757.78710420.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: castet.matthieu@free.fr, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:64502 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1750718AbWIWV7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 17:59:51 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060923.144757.78710420.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Larry Finger <Larry.Finger@lwfinger.net>
> Date: Sat, 23 Sep 2006 16:40:15 -0500
> 
>> The maximum value for MTU is set in include/linux/if_ether.h for all
>> ethernet-type communications, not in softmac or ieee80211. I doubt
>> that one could easily change the number. It may be that the 802.11
>> standard allows bigger frames, but it looks to me as if Linux does
>> not.
> 
> 
> Not correct.  Linux is perfectly fine with setting 9000 byte MTU on
> ethernet devices that support it, and in fact just about every
> gigabit ethernet driver supports it.
> 
> That macro you see in if_ether.h is just the value of the base MTU
> limit, so larger MTU settings are easily allowable on a per-device
> basis.

Where/how does the device allow it? When I tried 'ifconfig eth0 mtu 2000' on my VIA Technologies, 
Inc. VT6102 [Rhine-II] wired controller, I got a 'SIOCSIFMTU: Invalid argument' message, which is 
the same message I get on my BCM4306 wireless card.

Larry


