From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [patch net 2/2] mlxsw: spectrum: Don't sleep during
 ndo_get_phys_port_name()
Date: Thu, 9 Jun 2016 08:50:16 +0000
Message-ID: <CO2PR11MB008875CDB003CB79FF1FBCC0975F0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1465458700-5744-1-git-send-email-jiri@resnulli.us>
 <1465458700-5744-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"idosch@mellanox.com" <idosch@mellanox.com>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	"yotamg@mellanox.com" <yotamg@mellanox.com>,
	"nogahf@mellanox.com" <nogahf@mellanox.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0107.outbound.protection.outlook.com ([157.56.110.107]:53364
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754730AbcFIIuU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 04:50:20 -0400
In-Reply-To: <1465458700-5744-3-git-send-email-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> When rtnl_fill_ifinfo() is called for a certain netdevice it queries its various
> parameters such as switch id and physical port name. The function might get
> called in an atomic context, which means the underlying driver must not sleep

Is Documentation/networking/netdevices.txt a deprecated file?
If not, perhaps we should update such information there; Otherwise its trial
and  error for everyone.
