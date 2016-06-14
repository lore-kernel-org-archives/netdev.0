From: <Mario_Limonciello@Dell.com>
Subject: RE: [PATCH v6] r8152: Add support for setting pass through MAC
 address on RTL8153-AD
Date: Tue, 14 Jun 2016 17:58:02 +0000
Message-ID: <c18e2e127e334ffeb3712f54bb1480f4@ausx13mpc124.AMER.DELL.COM>
References: <1465323757-7249-1-git-send-email-mario_limonciello@dell.com>
 <201606141828.10969@pali> <20160614164017.GB14477@kroah.com>
 <201606141847.36109@pali>
 <ba393fe424fd4a8fb82703dd0f42eea7@ausx13mpc124.AMER.DELL.COM>
 <20160614172304.GB4914@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <pali.rohar@gmail.com>, <gregkh@linuxfoundation.org>,
	<davem@davemloft.net>, <hayeswang@realtek.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, <anthony.wong@canonical.com>
To: <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from AUSXIPPS310.us.dell.com ([143.166.148.211]:13657 "EHLO
	ausxipps310.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752662AbcFNR6F convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 13:58:05 -0400
In-Reply-To: <20160614172304.GB4914@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Tuesday, June 14, 2016 12:23 PM
> To: Limonciello, Mario <Mario_Limonciello@Dell.com>
> Cc: pali.rohar@gmail.com; gregkh@linuxfoundation.org;
> davem@davemloft.net; hayeswang@realtek.com; linux-
> kernel@vger.kernel.org; netdev@vger.kernel.org; linux-
> usb@vger.kernel.org; anthony.wong@canonical.com
> Subject: Re: [PATCH v6] r8152: Add support for setting pass through MAC
> address on RTL8153-AD
> 
> > > It is same, how to handle two network cards which tell us, that they
> > > have same MAC addresses.
> > >
> >
> > The kernel handles this just fine.  In doing this patch I checked to see
> > what it does in that scenario.  Two devices are made.  systemd doesn't
> > rename the second device via the MAC name (eg enxAABBCCDDEEFF).
> 
> What does you dhcp server do? Does it gives out the same IP address?
> You then have two interfaces on the same network, with the same MAC
> address and IP address. Then what happens?
> 
>      Andrew

I didn't test it on the same network, I used two separate networks.

I expect that the DHCP server would be awfully confused and you'd
run down an interesting problem path if it got the same MAC twice.
