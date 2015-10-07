From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 0/3] net: remove dsa.h from netdevice.h
Date: Wed, 7 Oct 2015 19:20:24 +0200
Message-ID: <20151007172024.GH2152@nanopsycho.orion>
References: <1444168467-10293-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:37585 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754518AbbJGRU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 13:20:27 -0400
Received: by wicfx3 with SMTP id fx3so38562718wic.0
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 10:20:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1444168467-10293-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 06, 2015 at 11:54:24PM CEST, vivien.didelot@savoirfairelinux.com wrote:
>In order to push switchdev objects down to DSA drivers, I need to include
>switchdev.h in dsa.h. But compilation fails because of a circular dependency
>issue, since dsa.h is also included in linux/netdevice.h.
>
>dsa.h is included for two purposes: to have the definition of struct
>dsa_switch_tree; and to have access to dsa_uses_tagged_protocol(), used by
>netdev_uses_dsa().
>
>This patchset forward declares struct dsa_switch_tree; adds a new uses_hw_tag
>boolean to struct net_device, which is more explicit than the DSA helper, and
>finally get rid of the dsa.h include.
>
>With this patchset, switchdev.h can safely be included in dsa.h.

Looks fine to me. I think that you should push this along with your
other patchset which actually needs this.

Thanks!
