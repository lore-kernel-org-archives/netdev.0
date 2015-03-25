From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: dsa: Handle non-bridge master change
Date: Wed, 25 Mar 2015 10:09:04 -0700
Message-ID: <5512EBB0.5020105@gmail.com>
References: <1427296117-1805-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Scott Feldman <sfeldma@gmail.com>,
	netdev@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:33916 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754056AbbCYRJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 13:09:50 -0400
Received: by pdbni2 with SMTP id ni2so34459097pdb.1
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 10:09:49 -0700 (PDT)
In-Reply-To: <1427296117-1805-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/03/15 08:08, Guenter Roeck wrote:
> Master change notifications may occur other than when joining or
> leaving a bridge, for example when being added to or removed from
> a bond or Open vSwitch. In that case, do nothing instead of asking
> the switch driver to remove a port from a bridge that it didn't join.
> 
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
