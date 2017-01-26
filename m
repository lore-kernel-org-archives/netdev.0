From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/4] net: dsa: Pass device pointer to
 dsa_register_switch
Date: Thu, 26 Jan 2017 10:37:31 -0800
Message-ID: <ddfc22b3-f89e-4756-2585-dcf5cada7a23@gmail.com>
References: <20170126182808.13435-1-f.fainelli@gmail.com>
 <20170126182808.13435-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34147 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752168AbdAZShd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 13:37:33 -0500
Received: by mail-pg0-f65.google.com with SMTP id 3so5206388pgj.1
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 10:37:33 -0800 (PST)
In-Reply-To: <20170126182808.13435-2-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/26/2017 10:28 AM, Florian Fainelli wrote:
> In preparation for allowing dsa_register_switch() to be supplied with
> device/platform data, pass down a struct device pointer instead of a
> struct device_node.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Need to revisit this:

drivers/net/dsa/mv88e6xxx/chip.c: In function 'mv88e6xxx_probe':
drivers/net/dsa/mv88e6xxx/chip.c:4460:3: error: implicit declaration of
function 'mv88e6xxx_mdio_unregister' [-Werror=implicit-function-declaration]
   mv88e6xxx_mdio_unregister(chip);
   ^
cc1: some warnings being treated as errors
scripts/Makefile.build:293: recipe for target
'drivers/net/dsa/mv88e6xxx/chip.o' failed
make[6]: *** [drivers/net/dsa/mv88e6xxx/chip.o] Error 1
scripts/Makefile.build:551: recipe for target
'drivers/net/dsa/mv88e6xxx' failed
make[5]: *** [drivers/net/dsa/mv88e6xxx] Error 2
make[5]: *** Waiting for unfinished jobs....

Take that kbuild robot!
-- 
Florian
