From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH] net: phy: micrel: KSZ9031: fix crash when statistic
 requested
Date: Tue, 11 Apr 2017 12:17:16 -0500
Message-ID: <a397cb88-4fd9-b34d-ab96-54604be7e6df@ti.com>
References: <20170410233324.1178-1-grygorii.strashko@ti.com>
 <e821198e-5a61-7912-d120-205f66c02650@gmail.com>
 <050b6778-276b-7094-36e1-1ccd06364766@ti.com>
 <20170411163628.GL27307@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170411163628.GL27307@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 04/11/2017 11:36 AM, Andrew Lunn wrote:
>> I've considered all this option, honestly, but I do not know if this
>> phys (issue should affect KSZ886X, KSZ8873MLL, KSZ9031, KSZ9021, KSZ8061, KS8737)
>> support fetching statistics or not and was hoping to get feedback from community.
>
> Hi Grygorii
>
> Microchip are one of the good guys. All there datesheets are open. So
> you should be able to check this.


Below is what i've found
			0xa 0x15 action
KS8737			-   +    remove stats? - reg 10(0xa) reserved
KSZ8061MNX/MNG		-   +	 remove stats? - reg 10(0xa) reserved
KSZ9021GN		+   +    add .probe()
KSZ9031 		+   +    add .probe()
KSZ8873MLL/FLL/RLL      -   -    remove stats
KSZ886X/KSZ8862		-   -    remove stats

The kszphy_probe() can be reused as .probe() callback as it seems
not phy specific.


-- 
regards,
-grygorii
