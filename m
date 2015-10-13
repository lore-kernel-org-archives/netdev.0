From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 3/6] net: dsa: mv88e6xxx: write MAC outside
 of ATU Get Next code
Date: Tue, 13 Oct 2015 11:43:56 -0700
Message-ID: <561D50EC.8010305@gmail.com>
References: <1444754783-26975-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1444754783-26975-4-git-send-email-vivien.didelot@savoirfairelinux.com> <561D40E9.8030602@gmail.com> <20151013181114.GA29391@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:32780 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbbJMSop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 14:44:45 -0400
In-Reply-To: <20151013181114.GA29391@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/10/15 11:11, Vivien Didelot wrote:
> On Oct. Tuesday 13 (42) 10:35 AM, Florian Fainelli wrote:
>> On 13/10/15 09:46, Vivien Didelot wrote:
>>> There is no need to write the MAC address before every Get Next
>>> operation, since ATU MAC registers are not cleared between calls.
>>>
>>> Move the _mv88e6xxx_atu_mac_write call outside of _mv88e6xxx_atu_getnext
>>> so future code could call ATU Get Next multiple times and save a few
>>> register access.
>>
>> Missing SoB tag here.
> 
> Damn, good catch. Can I add it in reply to the patch, or should I send a
> v3?

I am fairly positive patchwork should be able to pick it up, so replying
to your patch might just do it fine.
-- 
Florian
