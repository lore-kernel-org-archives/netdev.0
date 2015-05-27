From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: DSA and underlying 802.1Q encapsulation
Date: Wed, 27 May 2015 16:48:37 -0400 (EDT)
Message-ID: <1250227394.1145458.1432759717091.JavaMail.zimbra@savoirfairelinux.com>
References: <1183592753.514019.1432679397515.JavaMail.zimbra@savoirfairelinux.com> <20150526225142.GB26454@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Chris Healy <cphealy@gmail.com>,
	=?utf-8?Q?J=C3=A9rome?= Oufella
	<jerome.oufella@savoirfairelinux.com>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:60301 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbbE0Usk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 16:48:40 -0400
In-Reply-To: <20150526225142.GB26454@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Guenter,

> Interesting question. Does the underlying network device support VLAN HW
> acceleration (NETIF_F_HW_VLAN_CTAG_RX, NETIF_F_HW_VLAN_CTAG_TX) ?

Yes, in our case, it's an IGB device.

I also set the DSA slave_dev->features and slave_dev->vlan_features to
master->vlan_features | NETIF_F_VLAN_FEATURES | NETIF_F_HW_SWITCH_OFFLOAD, 
not sure if it is good or not.

> If yes, the dsa code may need to move the tag into the header.
> If we are lucky, a call to vlan_hwaccel_push_inside() might do it.

Thanks, I'm currently looking into it and doing some tests, I'm coming back to 
you asap.

> Do you have some vlan dsa code to share, by any chance ? That might
> save me some time, as I am looking into it as well.

Yes, I am about the send an RFC for fully integrated 802.1q VLAN support on 
Marvell 88E6352 devices.

Thanks,
-v
