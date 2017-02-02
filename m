From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCHv2 net-next 09/11] net: mvpp2: simplify MVPP2_PRS_RI_*
 definitions
Date: Thu, 2 Feb 2017 17:11:59 +0100
Message-ID: <20170202171159.353d80cc@free-electrons.com>
References: <1482943567-12483-1-git-send-email-thomas.petazzoni@free-electrons.com>
        <1482943567-12483-10-git-send-email-thomas.petazzoni@free-electrons.com>
        <20170106130727.GB14217@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Hanna Hawa <hannah@marvell.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        linux-arm-kernel@lists.infradead.org,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:55568 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750879AbdBBQMB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 11:12:01 -0500
In-Reply-To: <20170106130727.GB14217@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Fri, 6 Jan 2017 13:07:27 +0000, Russell King - ARM Linux wrote:

>   #define MVPP2_PRS_RI_L2_CAST_MASK              (BIT(10) | BIT(9))
>   #define MVPP2_PRS_RI_L2_UCAST                  0
>   #define MVPP2_PRS_RI_L2_MCAST                  BIT(9)
>   #define MVPP2_PRS_RI_L2_BCAST                  BIT(10)

Your comment makes perfect sense, so I've adopted this second option
you suggested. This is in my v3 I sent a few minutes ago.

Thanks!

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
