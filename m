From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net 2/2] mlxsw: spectrum: Don't sleep during
 ndo_get_phys_port_name()
Date: Thu, 9 Jun 2016 11:16:48 +0200
Message-ID: <20160609091648.GA1866@nanopsycho.amit.cz>
References: <1465458700-5744-1-git-send-email-jiri@resnulli.us>
 <1465458700-5744-3-git-send-email-jiri@resnulli.us>
 <CO2PR11MB008875CDB003CB79FF1FBCC0975F0@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"idosch@mellanox.com" <idosch@mellanox.com>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	"yotamg@mellanox.com" <yotamg@mellanox.com>,
	"nogahf@mellanox.com" <nogahf@mellanox.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34495 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbcFIJQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 05:16:53 -0400
Received: by mail-wm0-f65.google.com with SMTP id n184so9000412wmn.1
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 02:16:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CO2PR11MB008875CDB003CB79FF1FBCC0975F0@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jun 09, 2016 at 10:50:16AM CEST, Yuval.Mintz@qlogic.com wrote:
>> When rtnl_fill_ifinfo() is called for a certain netdevice it queries its various
>> parameters such as switch id and physical port name. The function might get
>> called in an atomic context, which means the underlying driver must not sleep
>
>Is Documentation/networking/netdevices.txt a deprecated file?
>If not, perhaps we should update such information there; Otherwise its trial
>and  error for everyone.

Looks like Documentation/networking/netdevices.txt needs a lot of work
to make it up to date. Would perhaps make sense to move this info
directly to the initial comment of struct net_device_ops.
