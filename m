From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH net-next 0/2] Work around missing PHY prodcut ID in mv88e6390
Date: Fri, 27 Jan 2017 18:12:09 +0100
Message-ID: <87fuk4whp2.fsf@free-electrons.com>
References: <1485309314-23942-1-git-send-email-andrew@lunn.ch>
        <20170125.132509.1614793375095964218.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        vivien.didelot@savoirfairelinux.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:60764 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933223AbdA0Rgu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 12:36:50 -0500
In-Reply-To: <20170125.132509.1614793375095964218.davem@davemloft.net> (David
        Miller's message of "Wed, 25 Jan 2017 13:25:09 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,
 
 On mer., janv. 25 2017, David Miller <davem@davemloft.net> wrote:

> From: Andrew Lunn <andrew@lunn.ch>
> Date: Wed, 25 Jan 2017 02:55:12 +0100
>
>> The internal PHYs of the MV88E6390 have a Marvell OUI, but the product
>> ID is zero. Work around this by trapping reads to the ID, and if it is
>> zero, return the MV88E6390 family ID.
>
> Because of the ID masking issue, I am expecting a respin of this.

Do you think you will send a new version soon?

It is the last missing part to send my v7 for the Topaz support on the
EspressoBin.

Thanks,

Gregory

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
