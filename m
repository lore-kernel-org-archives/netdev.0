From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Debugging Ethernet issues
Date: Sun, 13 Nov 2016 04:09:19 +0100
Message-ID: <20161113030919.GA2892@lunn.ch>
References: <5827AD4A.7010908@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Mans Rullgard <mans@mansr.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Tom Lendacky <thomas.lendacky@amd.com>,
        Zach Brown <zach.brown@ni.com>,
        Shaohui Xie <shaohui.xie@nxp.com>,
        Tim Beale <tim.beale@alliedtelesis.co.nz>,
        Brian Hill <brian@houston-radar.com>,
        Vince Bridgers <vbridgers2013@gmail.com>,
        Balakumaran Kannan <kumaran.4353@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Sebastian Frias <sf84@laposte.net>,
        Kirill Kapranov <kapranoff@inbox.ru>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36631 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753256AbcKMDJ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Nov 2016 22:09:28 -0500
Content-Disposition: inline
In-Reply-To: <5827AD4A.7010908@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> When connected to a Gigabit switch
> 3.4 negotiates a LAN DHCP setup instantly
> 4.7 requires over 5 seconds to do so

When you run tcpdump on the DHCP server, are you noticing the first
request is missing?

What can happen is the dhclient gets started immediately and sends out
its first request before auto-negotiation has finished. So this first packet
gets lost. The retransmit after a few seconds is then successful.

     Andrew
