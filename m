From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next] switchdev: bring back switchdev_obj and use it
 as a generic object param
Date: Wed, 30 Sep 2015 20:44:55 -0700
Message-ID: <CAE4R7bDOAvR4WKJ5-_Tpx_MOgA=9Eo=rDASUD3pTRitAo1mjMA@mail.gmail.com>
References: <1443628815-25095-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>, Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:34337 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754929AbbJADpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 23:45:15 -0400
Received: by obbda8 with SMTP id da8so48177047obb.1
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 20:45:14 -0700 (PDT)
In-Reply-To: <1443628815-25095-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 30, 2015 at 9:00 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Replace "void *obj" with a generic structure. Introduce couple of
> helpers along that.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Looks good to me, except for the macro/enum collision Vivien pointed
out.  Vivien's suggestion to use SWITCHDEV_OBJ_ID_xxx for ID enums
would work.

Actually, id should be moved back into switchdev_obj, otherwise that
info is lost in dump callbacks.  Could have a common callback that
switches on id, for id specific work.  I'll submit a patch to move id
back into obj if Jiri doesn't add it to this one.
