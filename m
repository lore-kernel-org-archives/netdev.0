From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 4/6] net: dsa: remove unused arguments of
 tagger rcv
Date: Tue, 30 May 2017 12:03:08 -0700
Message-ID: <b31811c6-d019-da1f-9df0-0ad00264204b@gmail.com>
References: <20170530183319.10718-1-vivien.didelot@savoirfairelinux.com>
 <20170530183319.10718-5-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170530183319.10718-5-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Vivien,

On 05/30/2017 11:33 AM, Vivien Didelot wrote:
> The struct dsa_device_ops defines the rcv function with 2 unused
> arguments struct packet_type *pt, and struct net_device *orig_dev.
> 
> This patch removes them from the definition and implementations.
> 
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

I actually have a patch pending that adds support for HW
insertion/extraction of switch tags (broadcom HW supports that) which
require the orig_dev to be there so we know what features are supported
by the master network device.

Do you mind dropping this one from your patch series?

Thanks!
-- 
Florian
