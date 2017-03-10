From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 07/14] net: dsa: mv88e6xxx: rework ATU Remove
Date: Fri, 10 Mar 2017 03:33:17 +0100
Message-ID: <20170310023317.GJ22101@lunn.ch>
References: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
 <20170309233324.18539-8-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170309233324.18539-8-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -static int _mv88e6xxx_atu_cmd(struct mv88e6xxx_chip *chip, u16 fid, u16 cmd)
> -{
> -	u16 val;
> -	int err;
> -
> -	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G1_ATU_FID)) {
> -		err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_FID, fid);
> -		if (err)
> -			return err;

I think this removal makes MV88E6XXX_FLAG_G1_ATU_FID unused. It should
be removed from mv88e6xxx.h as well.

   Andrew
