From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Patch for link detection for R8169
Date: Tue, 06 Sep 2005 21:56:01 -0400
Message-ID: <431E48B1.7050600@pobox.com>
References: <431DA887.2010008@zabrze.zigzag.pl> <20050906194602.GA20862@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Miroslaw Mieszczak <mieszcz@zabrze.zigzag.pl>,
	linux-kernel@vger.kernel.org, Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751197AbVIGB4J@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050906194602.GA20862@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Miroslaw Mieszczak <mieszcz@zabrze.zigzag.pl> :
> 
>>There is a patch to driver of RLT8169 network card. This match make 
>>possible detection of the link status even if network interface is down.
>>This is usefull for laptop users.
> 
> 
> (side note: there is maintainer entry for the r8169 and network related
> patches are welcome on netdev@vger.kernel.org)
> 
> Can you elaborate why it is usefull for laptop users ?
> 
> I am sceptical: tg3/bn2x/skge do not seem to allow it either.
> 
> Jeff, is it a requirement ?

Generally most drivers power down hardware, MAC at least, when the 
interface is down.  As such, many drivers do not (cannot), as written, 
report any useful link information.

IF the phy is not powered down, when the interface goes down, and IF 
hardware permits, it would certainly be nice to report link state when 
interface is down.  This is a hardware-dependent, driver-dependent choice.

	Jeff
