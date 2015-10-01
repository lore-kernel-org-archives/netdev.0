From: Jiri Pirko <jiri@mellanox.com>
Subject: Re: [patch net-next] switchdev: bring back switchdev_obj and use it
 as a generic object param
Date: Thu, 1 Oct 2015 08:04:39 +0200
Message-ID: <20151001060439.GA2156@nanopsycho.orion>
References: <1443628815-25095-1-git-send-email-jiri@resnulli.us>
 <CAE4R7bDOAvR4WKJ5-_Tpx_MOgA=9Eo=rDASUD3pTRitAo1mjMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, <eladr@mellanox.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0093.outbound.protection.outlook.com ([157.55.234.93]:63621
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750921AbbJAGUt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2015 02:20:49 -0400
Content-Disposition: inline
In-Reply-To: <CAE4R7bDOAvR4WKJ5-_Tpx_MOgA=9Eo=rDASUD3pTRitAo1mjMA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 01, 2015 at 05:44:55AM CEST, sfeldma@gmail.com wrote:
>On Wed, Sep 30, 2015 at 9:00 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> Replace "void *obj" with a generic structure. Introduce couple of
>> helpers along that.
>>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>
>Looks good to me, except for the macro/enum collision Vivien pointed
>out.  Vivien's suggestion to use SWITCHDEV_OBJ_ID_xxx for ID enums
>would work.

ok

>
>Actually, id should be moved back into switchdev_obj, otherwise that
>info is lost in dump callbacks.  Could have a common callback that
>switches on id, for id specific work.  I'll submit a patch to move id
>back into obj if Jiri doesn't add it to this one.

I was thinking about it as well and it makes sense. I'll add it.
