From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next] bridge: try switchdev op first in __vlan_vid_add/del
Date: Fri, 9 Oct 2015 20:12:03 -0700
Message-ID: <CAE4R7bBftWn0GyTHW4CAkKvzQ4i-fw8ttO2muNJjHWa2xiqJMg@mail.gmail.com>
References: <1444391651-13775-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	john fastabend <john.fastabend@gmail.com>,
	David Laight <David.Laight@aculab.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:34431 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbbJJDMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 23:12:23 -0400
Received: by oiak8 with SMTP id k8so39391191oia.1
        for <netdev@vger.kernel.org>; Fri, 09 Oct 2015 20:12:23 -0700 (PDT)
In-Reply-To: <1444391651-13775-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 9, 2015 at 4:54 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Some drivers need to implement both switchdev vlan ops and
> vid_add/kill ndos. For that to work in bridge code, we need to try
> switchdev op first when adding/deleting vlan id.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>

Acked-by: Scott Feldman <sfeldma@gmail.com>
