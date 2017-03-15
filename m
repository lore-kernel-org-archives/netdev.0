From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 2/3] net: dsa: check out-of-range ageing time
 value
Date: Wed, 15 Mar 2017 13:04:04 -0700
Message-ID: <bdc7c1a8-6ffc-ebd7-2650-476be1218903@gmail.com>
References: <20170315195350.11059-1-vivien.didelot@savoirfairelinux.com>
 <20170315195350.11059-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Jason Cobham <jcobham@questertangent.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170315195350.11059-3-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/15/2017 12:53 PM, Vivien Didelot wrote:
> If a DSA switch driver cannot program an ageing time value due to it
> being out-of-range, switchdev will raise a stack trace before failing.
> 
> To fix this, add ageing_time_min and ageing_time_max members to the
> dsa_switch in order for the switch drivers to optionally specify their
> supported ageing time limits.
> 
> The DSA core will now check for provided ageing time limits and return
> -ERANGE from the switchdev prepare phase if the value is out-of-range.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

You could simplify the two changes (and remove the check for
ds->ageing_time_{min,max} by setting ds->ageing_time_min to ~0 by
default. Absolutely not critical and the code is clear as-is.
-- 
Florian
