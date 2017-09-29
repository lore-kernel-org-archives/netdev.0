From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 3/8] net: dsa: use cpu_dp in master code
Date: Fri, 29 Sep 2017 12:10:56 -0700
Message-ID: <e15809d8-9178-ce4b-df44-b3693f9d4a55@gmail.com>
References: <20170929183635.8122-1-vivien.didelot@savoirfairelinux.com>
 <20170929183635.8122-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170929183635.8122-4-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/29/2017 11:36 AM, Vivien Didelot wrote:
> Make it clear that the master device is linked to a CPU port by using
> "cpu_dp" for the dsa_port variable in master.c instead of "port", then
> use a "port" variable to describe the port index, as usually seen in
> other places of DSA core.
> 
> This will make the future patch touching dsa_ptr more readable. There is
> no functional changes.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
