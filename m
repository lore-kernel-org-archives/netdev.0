From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] net: dsa: add support for switchdev VLAN objects
Date: Wed, 24 Jun 2015 09:05:15 +0200
Message-ID: <20150624070515.GA2088@nanopsycho.ki.iif.hu>
References: <1435079929-23018-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Scott Feldman <sfeldma@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:35144 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbbFXHFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 03:05:19 -0400
Received: by wgbhy7 with SMTP id hy7so27855196wgb.2
        for <netdev@vger.kernel.org>; Wed, 24 Jun 2015 00:05:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1435079929-23018-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jun 23, 2015 at 07:18:49PM CEST, vivien.didelot@savoirfairelinux.com wrote:
>This patch adds the glue between DSA and switchdev operations to add,
>delete and dump SWITCHDEV_OBJ_PORT_VLAN objects.
>
>This is a first step to link the "bridge vlan" command with hardware
>entries for DSA compatible switch chips.

Do you have some consumers of these new functions? I believe it is
necessary to have those in order for this patch to be accepted.

Thanks.
