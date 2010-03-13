From: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Subject: Re: Linux support for 802.3af?
Date: Fri, 12 Mar 2010 18:11:07 -0700
Message-ID: <4B9AE62B.6050502@redfish-solutions.com>
References: <4B9AD5CA.7000303@redfish-solutions.com> <1268440985.7439.23.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:38864 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935357Ab0CMBLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Mar 2010 20:11:39 -0500
In-Reply-To: <1268440985.7439.23.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/12/2010 05:43 PM, Ben Hutchings wrote:
> On Fri, 2010-03-12 at 17:01 -0700, Philip A. Prindeville wrote:
>> I was looking at this Marvell-based 4-port PCI card with PoE and
>> thinking it would be handy for powering cameras and ip-phones, but don't
>> remember seeing any kernel support for 802.3af...
>>
>> http://www.korenix.com/jetcard-PoE_Universal_PCI_Card-2215-overview.htm
>>
>> There's no support for 802.3af, right?
> 
> The standard MDIO ioctls can be used to access registers 11 and 12 on
> PHYs with integrated PSE functionality.  There is no way of indicating
> whether a PHY has such functionality, but a flag for this could be added
> to the mdio_support field of struct ethtool_cmd.
> 
> Ben.

Well, there's more to it than that, right?

There's a software state machine that's required to go through the handshake, there's prioritization and power budgeting, etc.  Yes?

What am I missing?



