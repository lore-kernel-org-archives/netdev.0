From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/2] mv88e6131: bonding: implement single device
 trunking
Date: Fri, 06 Mar 2015 09:06:50 -0800
Message-ID: <54F9DEAA.50606@gmail.com>
References: <1424429473-4601-1-git-send-email-jonasj76@gmail.com> <1424429473-4601-3-git-send-email-jonasj76@gmail.com> <20150220152644.GD13797@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Jonas Johansson <jonas.johansson@westermo.se>,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>, Jonas Johansson <jonasj76@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:41820 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752316AbbCFRHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 12:07:19 -0500
Received: by pdjy10 with SMTP id y10so6691139pdj.8
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 09:07:19 -0800 (PST)
In-Reply-To: <20150220152644.GD13797@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/02/15 07:26, Andrew Lunn wrote:
> On Fri, Feb 20, 2015 at 11:51:13AM +0100, Jonas Johansson wrote:
> 
> Please could you look at all your functions and see what is specific
> to the 6131 and what is generic. Place the generic code into mv88e6xxx
> please so we can all use it.

Out of curiosity, how many bonding/trunking groups are supported on the
switches models currently in tree?

Let's say there is a limitation: like no more than 2 different bonding
groups on a given physical switch, where would we put this limitation,
down to the switch driver?
-- 
Florian
