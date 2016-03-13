From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC PATCH net-next 0/3] net: dsa: finer bridging control
Date: Sun, 13 Mar 2016 14:40:16 -0400
Message-ID: <87h9ga1asv.fsf@ketchup.mtl.sfl>
References: <1457851346-26257-1-git-send-email-vivien.didelot@savoirfairelinux.com> <20160313174713.GC10666@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Ido Schimmel <idosch@mellanox.com>,
	Kevin Smith <kevin.smith@elecsyscorp.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:44804 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752589AbcCMSkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 14:40:21 -0400
In-Reply-To: <20160313174713.GC10666@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Sun, Mar 13, 2016 at 01:42:23AM -0500, Vivien Didelot wrote:
>> This patchset renames the bridging routines of the DSA layer, make the
>> unbridging routine return void, and rework the DSA netdev notifier handler,
>> similar to what the Mellanox Spectrum driver does.
>
> Tested-by: Andrew Lunn <andrew@lunn.ch>
>
> Do you think there could be some consolidation of code with Mellanox,
> and other switchdev devices? Moving it into the switchdev core?

We cannot move all this code to switchdev core, because switchdev is
stateless, so there is no place to register the netdevice notifier(s).

But it might be possible to provide a generic switchdev_netdevice_event
helper, using new switchdev operations to check a port device, and
add/del upper devices. I'll think about that.

Thanks!
Vivien
