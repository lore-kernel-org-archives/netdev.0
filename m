From: Ivan Frederiks <frederiks@speechpro.com>
Subject: Re: Realtek RTL8102E registers
Date: Wed, 06 Nov 2013 14:13:14 +0400
Message-ID: <527A163A.9010409@speechpro.com>
References: <526FCEAA.30102@speechpro.com> <20131029214059.GA26496@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux r8169 crew <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spb2.speechpro.com ([149.126.18.58]:59366 "EHLO
	spb2.speechpro.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756185Ab3KFKN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 05:13:28 -0500
In-Reply-To: <20131029214059.GA26496@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Francois,

I found solution for the issue that I described earlier: one has to set
correct MAC-address before bringing up the interface.

On my board RTL8102E works without EEPROM, so initial MAC-address value
is unpredictable. In many cases this value has multicast bit set to 1.
This fact breaks driver and (or) TCP stack operation:
* r8169 reports that link is down
* r8101 reports that link is OK, but Linux TCP stack ignores packets
with multicast destination MAC

Hope this info would be useful. BTW, I suppose that driver could have
some kind of protection against such situations.

On 30.10.2013 01:40, Francois Romieu wrote:
> Ivan Frederiks <frederiks@speechpro.com> :
> [...]
>> Maybe you have access to RTL8102E register description ?
> 
> No.
> 
> Realtek's hardware documentation policy isn't exactly opened. Your hardware
> vendor may help.
> 
> [...]
>> Issue description:
> [snip]
> 
> kernel version and r81xx XID value as it should appear in dmesg would
> be welcome.
> 

--
Best regards,

Ivan Frederiks
Embedded developer
Speech Technology Center

Phone: +7-812-331-0665, ext. 6123, 6942
Fax: +7-812-327-9297
