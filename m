From: Stefan Eichenberger <eichest@gmail.com>
Subject: Re: [PATCH v2 net-next v2 4/4] net: dsa: mv88e6xxx: add PPU
 operations
Date: Mon, 5 Dec 2016 22:04:39 +0100
Message-ID: <20161205210439.GA6038@eichest-notebook>
References: <20161205162703.22567-1-vivien.didelot@savoirfairelinux.com>
 <20161205162703.22567-5-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Richard Cochran <richardcochran@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33026 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751488AbcLEVEo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 16:04:44 -0500
Content-Disposition: inline
In-Reply-To: <20161205162703.22567-5-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vivien,

On Mon, Dec 05, 2016 at 11:27:03AM -0500, Vivien Didelot wrote:
> @@ -3266,6 +3220,8 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
>  	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
>  	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
>  	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
> +	.ppu_enable = mv88e6185_g1_ppu_enable,
> +	.ppu_disable = mv88e6185_g1_ppu_disable,
>  	.reset = mv88e6185_g1_reset,
>  };

The mv88e6097 should use the indirect access to the phys, bit 14 in g1
control is marked as reserved. They write in the datasheet that
disabling the PPU is still supported but indirect access via g2 should
be used because disabling the PPU  is no longer recommended.

Best regards,
Stefan
