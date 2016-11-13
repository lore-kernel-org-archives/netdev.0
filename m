From: Mason <slash.tmp@free.fr>
Subject: Re: Debugging Ethernet issues
Date: Sun, 13 Nov 2016 20:51:46 +0100
Message-ID: <5828C452.6050808@free.fr>
References: <5827AD4A.7010908@free.fr> <20161113030919.GA2892@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
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
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:59912 "EHLO smtp2-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934302AbcKMTw3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 13 Nov 2016 14:52:29 -0500
In-Reply-To: <20161113030919.GA2892@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/11/2016 04:09, Andrew Lunn wrote:

> Mason wrote:
>
>> When connected to a Gigabit switch
>> 3.4 negotiates a LAN DHCP setup instantly
>> 4.7 requires over 5 seconds to do so
> 
> When you run tcpdump on the DHCP server, are you noticing the first
> request is missing?
> 
> What can happen is the dhclient gets started immediately and sends out
> its first request before auto-negotiation has finished. So this first packet
> gets lost. The retransmit after a few seconds is then successful.

I will run tcpdump on the server as I run udhcpc on the client
for Linux 3.4 vs 4.7

Do you know what would make auto-negotiation fail at 100 Mbps
on 4.7? (whereas it succeeds on 3.4)

(Thinking out loud) If the problem were in auto-negotiation,
then if should work if I hard-code speed and duplex using
ethtool, right? (IIRC, hard-coding doesn't help.)

Regards.
