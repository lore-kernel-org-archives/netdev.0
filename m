From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 3/3] net: dsa: Allow configuration of CPU & DSA port
 speeds/duplex
Date: Wed, 17 Jun 2015 14:09:52 -0400 (EDT)
Message-ID: <536480200.118000.1434564592107.JavaMail.zimbra@savoirfairelinux.com>
References: <1434129537-15252-1-git-send-email-andrew@lunn.ch> <1434129537-15252-3-git-send-email-andrew@lunn.ch> <557F0CD5.4070705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, David <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:64035 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755656AbbFQSJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 14:09:55 -0400
In-Reply-To: <557F0CD5.4070705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew, All,

On 12/06/15 10:18, Andrew Lunn wrote:
> By default, DSA and CPU ports are configured to the maximum speed the
> switch supports. However there can be use cases where the peer device
> port is slower. Allow a fixed-link property to be used with the DSA
> and CPU port in the device tree, and use this information to configure
> the port.

Would it be a good idea for DSA to expose the "cpu" port to userspace as well?
That way, it'd be possible to use ethtool to set the port speed and duplex
mode, or dump registers (this would have saved me quite some time in dev).

Also, in my RFC for 802.1Q support [1], I assume the CPU port to be a tagged
member of each VLAN. But someone may want to add a VLAN with swp3 and swp4
only, and another VLAN with swp0, swp1 and the CPU port. Am I correct? This is
currently not possible, but with an exposed "cpu" interface, the user could
explicitly add the CPU port to a VLAN.

Sorry if this is a bit off-topic.

[1] https://lkml.org/lkml/2015/6/1/752

Thanks,
-v
