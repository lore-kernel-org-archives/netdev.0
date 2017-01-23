From: =?UTF-8?Q?Sean_Nyekj=c3=a6r?= <sean.nyekjaer@prevas.dk>
Subject: Re: [PATCH] net: phy: micrel: add KSZ8795 ethernet switch
Date: Mon, 23 Jan 2017 08:22:41 +0100
Message-ID: <439ce341-6a96-6ac7-1a2f-30340b32b2ad@prevas.dk>
References: <20170120125049.121307-1-sean.nyekjaer@prevas.dk>
 <20170120141728.GA13115@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail01.prevas.se ([62.95.78.3]:1240 "EHLO mail01.prevas.se"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750703AbdAWHWo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 02:22:44 -0500
In-Reply-To: <20170120141728.GA13115@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017-01-20 15:17, Andrew Lunn wrote:
> On Fri, Jan 20, 2017 at 01:50:49PM +0100, Sean Nyekjaer wrote:
>> This ethernet switch have unfortunately the same phy id as KSZ8051.
> Hi Sean
>
> Please could you explain some more. You are adding PHY support here,
> not switch support. So is this to enable the PHY driver for the PHYs
> embedded in the switch?
>
> 	 Andrew
Yes of couse :-)
The KSZ8051 is a 5 port managed ethernet switch with integrated PHY with 
MII/RMII interface on one port.
Through the MDIO interface is possible to control the PHY on port 1-5.

I have just seen an issue with the reported speed and duplex, so i'm 
gonna submit a new version with a better description

/Sean
