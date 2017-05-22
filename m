From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 08/20] net: dsa: change scope of ageing time
 setter
Date: Mon, 22 May 2017 12:29:10 -0700
Message-ID: <ed9cd9e7-da23-f841-f5a4-a1ba8e09db76@gmail.com>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
 <20170519210055.9366-9-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170519210055.9366-9-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/19/2017 02:00 PM, Vivien Didelot wrote:
> Change the scope of the switchdev bridge ageing time attribute setter
> from the DSA slave device to the generic DSA port, so that the future
> port-wide API can also be used for other port types, such as CPU and DSA
> links.
> 
> Also ds->ports is now a contiguous array of dsa_port structures, thus
> their addresses cannot be NULL. Remove the useless check in
> dsa_fastest_ageing_time.

And you are also passing just the ageing time value, and not longer the
full attribute, which is a nice simplification.

> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
