From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] phylib: Fix Freescale TBI PHY detection
Date: Wed, 14 Jan 2009 12:20:35 -0600
Message-ID: <4DDB8462-ACB6-494A-A1CB-4F56668A4EE1__33835.4590967812$1231957450$gmane$org@freescale.com>
References: <20090113160513.GA22083@oksana.dev.rtsoft.ru> <20090114150332.GA839@oksana.dev.rtsoft.ru>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Giulio Benetti <giulio.benetti@micronovasrl.com>
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:48717 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752726AbZANSWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 13:22:32 -0500
In-Reply-To: <20090114150332.GA839@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 14, 2009, at 9:03 AM, Anton Vorontsov wrote:
>>
>> There is one thing I don't actually understand though...
>>
>> Andy, were you testing the TBI support on a hardware where PHY ID
>> != 0x0 or maybe your TBI PHY support patch (commit b31a1d8b41513b,
>> dated Tue Dec 16 15:29:15 2008) was based on a bit outdated kernel
>> version? Because according to the git timestamps, the TBI support
>> was not working since the submission.
>>
>> Just in case, the hardware I'm seeing the PHY ID == 0x0 is
>> MPC8378E-MDS.
>
> I think I got it. Probably the TBI support patch was based on the
> powerpc.git next, and the commit that broke the TBI support
> was in the net-next-2.6 tree.
>
> That explains why nobody noticed the issue.


Yeah, I dropped the ball.  I saw the patch go in, thought that might  
break something, but I didn't find time to look into it.  Thanks for  
finding and reverting this bug.

Acked-by: Andy Fleming <afleming@freescale.com>
