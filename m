From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v4 1/4] net: dsa: Add plumbing for port mirroring
Date: Mon, 30 Jan 2017 07:36:15 +0100
Message-ID: <20170130063615.GA1908@nanopsycho.orion>
References: <20170130043026.28867-1-f.fainelli@gmail.com>
 <20170130043026.28867-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, cphealy@gmail.com,
        jiri@mellanox.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33018 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751328AbdA3GgS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 01:36:18 -0500
Received: by mail-wm0-f68.google.com with SMTP id v77so14083237wmv.0
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 22:36:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170130043026.28867-2-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jan 30, 2017 at 05:30:23AM CET, f.fainelli@gmail.com wrote:
>Add necessary plumbing at the slave network device level to have switch
>drivers implement ndo_setup_tc() and most particularly the cls_matchall
>classifier. We add support for two switch operations:
>
>port_add_mirror and port_del_mirror() which configure, on a per-port
>basis the mirror parameters requested from the cls_matchall classifier.
>
>Code is largely borrowed from the Mellanox Spectrum switch driver.
>
>Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Jiri Pirko <jiri@mellanox.com>
