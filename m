From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 2/6] net: dsa: do not cast dst
Date: Tue, 30 May 2017 13:34:36 -0700
Message-ID: <147b2141-3e64-5141-40c9-86a024d54a15@gmail.com>
References: <20170530183319.10718-1-vivien.didelot@savoirfairelinux.com>
 <20170530183319.10718-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170530183319.10718-3-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/30/2017 11:33 AM, Vivien Didelot wrote:
> dsa_ptr is not a void pointer anymore since Nov 2011, as of cf50dcc24f82
> ("dsa: Change dsa_uses_{dsa, trailer}_tags() into inline functions"),
> but an explicit dsa_switch_tree pointer, thus remove the (void *) cast.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
