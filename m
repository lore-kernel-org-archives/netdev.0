From: Stefan Eichenberger <eichest@gmail.com>
Subject: Re: [PATCH v2 net-next v2 3/4] net: dsa: mv88e6xxx: add a soft reset
 operation
Date: Mon, 5 Dec 2016 22:24:51 +0100
Message-ID: <20161205212451.GB6038@eichest-notebook>
References: <20161205162703.22567-1-vivien.didelot@savoirfairelinux.com>
 <20161205162703.22567-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Richard Cochran <richardcochran@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161205162703.22567-4-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Vivien

On Mon, Dec 05, 2016 at 11:27:02AM -0500, Vivien Didelot wrote:
>  static const struct mv88e6xxx_ops mv88e6097_ops = {
> @@ -3285,6 +3266,7 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
>  	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
>  	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
>  	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
> +	.reset = mv88e6185_g1_reset,
>  };

Because it is not necessary to disable/enable the PPU and bit 14 is
marked as reserved in the datasheet, I think the following should be
used instead:
.reset = mv88e6352_g1_reset

Regards,
Stefan
