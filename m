From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net/phy: micrel: Follow attached_dev to get to the MAC
 device
Date: Sat, 17 Oct 2015 02:32:30 +0300
Message-ID: <5621890E.8090704@cogentembedded.com>
References: <1445028545-22599-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
	Dinh Nguyen <dinguyen@opensource.altera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:34153 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817AbbJPXcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 19:32:33 -0400
Received: by lbbwb3 with SMTP id wb3so48792997lbb.1
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 16:32:32 -0700 (PDT)
In-Reply-To: <1445028545-22599-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/2015 11:49 PM, Andrew Lunn wrote:

> Commit "8b63ec1837fa phylib: Make PHYs children of their MDIO bus, not
> the bus' parent." broke finding PHY properties in the MAC device tree

    You probably forgot to run checkpatch.pl on this patch, else it would have 
complained about the commit citing style. It's <12-bit SHA1> ("<summary line>").

> node. The parent device is now the MDIO bus, not the MAC. Use
> attached_dev towards the MAC device tree node.
>
> Fixes: 8b63ec1837fa ("phylib: Make PHYs children of their MDIO bus, not the bus' parent.")

    Yeah, exactly like this.

> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
[...]

MBR, Sergei
