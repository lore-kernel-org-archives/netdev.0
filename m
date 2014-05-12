From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169/r8168 slow internet upload
Date: Mon, 12 May 2014 07:44:47 +0200
Message-ID: <20140512054447.GA17153@electric-eye.fr.zoreil.com>
References: <20140511231946.GA12504@offline.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Marc Duponcheel <marc@offline.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:37516 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340AbaELFox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 01:44:53 -0400
Content-Disposition: inline
In-Reply-To: <20140511231946.GA12504@offline.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marc Duponcheel <marc@offline.be> :
[...]
>  I have an issue with linux box acting as router (in fact forwarder)
> with 2 Realtek RTL8111/8168/8411 cards.
> 
>  In short: large file uploads are way too slow and, during such
> uploads, I see TcpRetransSegs and TcpOutRsts on sending host.
> 
>  System is bleeding edge gentoo.

Please specify kernel version.

[...]
> * r8169:
> 
>  Incoming speed is OK (50Mbps) but outgoing is only 200Kbps. 30 times
> too slow.

Please send plain ethtool output and network capture file for the outgoing
traffic.

>  Now I set eth speeds to 100Mbps (on linux-router, I never touch
> linux-server who works fine anyway for years with cisco-router):
> 
>  Outgoing speed to few hops away is 2Mbps and to many hops away still 200Kbps.

A capture file for each of those would be welcome.

[...]
> * replace r8169 with r8168:
> 
>  Outgoing to few hops away is 3Mbps and to many hops away is 1.5Mbps.

Same capture as above will be welcome.

[...]
> Am I missing something obvious? Or are the RTL8111/8168/8411
> cards/drivers not good for this setup? Any other hints? I am happy to
> do whatever tests and provide whatever outputs that may help drive
> discussion.

Nothing obvious on the driver side. There could be an r816x hardware bug
thus some (small) packets loss.

Please send a complete dmesg including the 'XID' line from the r8169
driver.

Thanks.

-- 
Ueimor
