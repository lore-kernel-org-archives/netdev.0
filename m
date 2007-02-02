From: Fagyal Csongor <concept@conceptonline.hu>
Subject: Re: sky2 hangs
Date: Fri, 02 Feb 2007 12:53:56 +0100
Message-ID: <45C32654.3060602@conceptonline.hu>
References: <20070201185532.GL13130@cip.informatik.uni-erlangen.de> <42007.80.98.159.250.1170369983.squirrel@www.hunhost.com> <20070201145815.199bfe1a@freekitty> <20070202063104.GA13130@cip.informatik.uni-erlangen.de> <873b5o25zs.fsf@sonic.technologeek.org> <20070202104918.GD1693@cip.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Julien BLACHE <jb@jblache.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Thomas Glanzmann <thomas@glanzmann.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.interware.hu ([195.70.32.130]:60207 "EHLO
	mail.interware.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932666AbXBBLzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Feb 2007 06:55:25 -0500
In-Reply-To: <20070202104918.GD1693@cip.informatik.uni-erlangen.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Glanzmann wrote:

>Hello,
>
>  
>
>>Next time sky2 hangs on me I'll try to reset the PHY and see if that
>>helps. I can usually trigger the hang by doing a couple of ifconfig
>>up/down on the interface, though I'm not getting any error message
>>from the driver when that happens.
>>    
>>
>
>same for me. In dmesg is absolut nothing. I change my fix script, too.
>To see if that is enough to resolv the problem.
>  
>
Well, ethtool -r eth0 did not work for me. :(

This time I got nothing in the log.

When I say ethtool -r eth0, I have this:
sky2 eth0: Link is up at 1000 Mbps, full duplex, flow control both

But the interface stays down. (Maybe the other end got confused?)


- Cs.

