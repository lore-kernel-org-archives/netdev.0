From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: brcmsmac crashed 3.3-rc5 kernel
Date: Wed, 7 Mar 2012 18:57:02 +0100
Message-ID: <4F57A16E.8010701@broadcom.com>
References: <1331136086.2168.0@numa-i>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
To: "Helmut Jarausch" <jarausch@igpm.rwth-aachen.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1793 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756440Ab2CGR5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2012 12:57:16 -0500
In-Reply-To: <1331136086.2168.0@numa-i>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/07/2012 05:01 PM, Helmut Jarausch wrote:
> Hi Arend,
> thanks for your interest.
>
> Unfortunately, I have no experience in kernel debugging.
> If I switch on several flags in the 'kernel hacking' section, I get
> losts of information on screen - but I don't know how capture these on
> disk.

Sometimes your last resort is using a digital camera to capture what is 
showing on your screen. Can you do that and sent me the picture?

> Meanwhile I have found out that the brcmsmac driver does work under
> special circumstances.
>
> My notebook (HP 625) has to NICs - ethernet and Wlan (BCM4313).
> If I disconnect my PC from the internet, or configure it not to start
> the ethernet connection, then I can start the WLAN successfully - and
> it even seems to be stable.

What happens when you start ethernet after WLAN?

> On the other hand, if I start the ethernet (RTL8101E/RTL8102E) first
> and try to start the WLAN next, the kernel crashes each time as
> reported.

Maybe an issue with shared interrupts. Can you provide the lspci output 
(ie. lspci -v) to me.

> I can live with this situation but if you like me to find out what's
> going on I'm willing to help. But for that I need your help on kernel
> debugging first (currently 3.3-rc6)

Safe the good stuff for later ;-)

Gr. AvS
