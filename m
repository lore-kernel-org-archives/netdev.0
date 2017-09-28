From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next RFC 1/9] net: dsa: mv88e6xxx: add accessors for PTP/TAI registers
Date: Thu, 28 Sep 2017 12:29:24 -0400
Message-ID: <87o9puaisb.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com> <1506612341-18061-2-git-send-email-brandon.streiff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Richard Cochran <richardcochran@gmail.com>,
        Erik Hons <erik.hons@ni.com>,
        Brandon Streiff <brandon.streiff@ni.com>
To: Brandon Streiff <brandon.streiff@ni.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506612341-18061-2-git-send-email-brandon.streiff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Brandon,

Brandon Streiff <brandon.streiff@ni.com> writes:

> +	.port_ptp_read		= mv88e6352_port_ptp_read,
> +	.port_ptp_write		= mv88e6352_port_ptp_write,
> +	.ptp_read		= mv88e6352_ptp_read,
> +	.ptp_write		= mv88e6352_ptp_write,
> +	.tai_read		= mv88e6352_tai_read,
> +	.tai_write		= mv88e6352_tai_write,

> +	.port_ptp_read		= mv88e6390_port_ptp_read,
> +	.port_ptp_write		= mv88e6390_port_ptp_write,
> +	.ptp_read		= mv88e6390_ptp_read,
> +	.ptp_write		= mv88e6390_ptp_write,
> +	.tai_read		= mv88e6390_tai_read,
> +	.tai_write		= mv88e6390_tai_write,

Only nitpick: please keep the mv88e63{52,90}_g2_avb_ prefix here.

Otherwise thanks for respecting the code organization, very clear patch:

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>


             Vivien
