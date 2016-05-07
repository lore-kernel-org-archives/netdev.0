From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 15/21] net: dsa: mv88e6xxx: factorize VLAN Ethertype
Date: Sat, 07 May 2016 16:51:29 -0400
Message-ID: <8760upfv72.fsf@ketchup.mtl.sfl>
References: <1462571843-14397-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1462571843-14397-16-git-send-email-vivien.didelot@savoirfairelinux.com> <20160506223344.GE2073@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>, f@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:34239 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbcEGUvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 16:51:33 -0400
In-Reply-To: <20160506223344.GE2073@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Fri, May 06, 2016 at 05:57:17PM -0400, Vivien Didelot wrote:
>> The 6131 switch models have a Core Tag Type register. Add a
>> MV88E6XXX_FLAG_CORE_TAG_TYPE flag and set the VLAN Ethertype to 0x8100
>> in the shared setup code if it is present.
>
> Do you have any idea what the core tag is?

Core Tag Type is the global register 0x19 present only on 6185 and
similar. It is used when egressing double tagged frames. This value is
also checked when ingressing frames on ports in UseCoreTag mode.

Note that we might remove this flag and setup condition, because 0x8100
is the reset value anyway.

        Vivien
