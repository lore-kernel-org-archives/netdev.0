From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/5] net: dsa: add slave notify helper
Date: Thu, 12 Oct 2017 15:55:45 -0700
Message-ID: <ea79cc42-2873-65eb-0449-56f0ca4f941a@gmail.com>
References: <20171012225156.20758-1-vivien.didelot@savoirfairelinux.com>
 <20171012225156.20758-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171012225156.20758-3-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/12/2017 03:51 PM, Vivien Didelot wrote:
> Both DSA slave create and destroy functions call call_dsa_notifiers with
> respectively DSA_PORT_REGISTER and DSA_PORT_UNREGISTER and the same
> dsa_notifier_register_info structure.
> 
> Wrap this in a dsa_slave_notify helper so prevent cluttering these
> functions.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Much nicer, thanks!

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
