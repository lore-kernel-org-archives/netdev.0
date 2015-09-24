From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: Set a "dsa" device_type
Date: Thu, 24 Sep 2015 18:37:49 -0400
Message-ID: <20150924223748.GA6064@ketchup.mtl.sfl>
References: <1443057598-25729-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux@roeck-us.net, andrew@lunn.ch
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-208-88-110-44.savoirfairelinux.net ([208.88.110.44]:49226
	"EHLO mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753152AbbIXWhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 18:37:52 -0400
Content-Disposition: inline
In-Reply-To: <1443057598-25729-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Sep. Wednesday 23 (39) 06:19 PM, Florian Fainelli wrote:
> Provide a device_type information for slave network devices created by
> DSA, this is useful for user-space application to easily locate/search
> for devices of a specific kind.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Noob question, how is that used from user-space?

Also, don't you think that this "dsa" device type might be conflicting
with eventually exposed DSA ports? Or will they all get the same type?

Thanks,
-v
