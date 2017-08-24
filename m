From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] constify dsa_switch_ops
Date: Wed, 23 Aug 2017 22:30:44 -0700 (PDT)
Message-ID: <20170823.223044.860811579441677677.davem@davemloft.net>
References: <1503483419-21780-1-git-send-email-arvind.yadav.cs@gmail.com>
        <20170823124556.GC28612@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arvind.yadav.cs@gmail.com, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170823124556.GC28612@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed, 23 Aug 2017 14:45:56 +0200

> On Wed, Aug 23, 2017 at 03:46:56PM +0530, Arvind Yadav wrote:
>> dsa_switch_ops are not supposed to change at runtime. All functions
>> working with dsa_switch_ops provided by <net/dsa.h> work with
>> const dsa_switch_ops. So mark the non-const structs as const.
>> 
>> Arvind Yadav (3):
>>   [PATCH 1/3] net: dsa: loop: constify dsa_switch_ops
>>   [PATCH 2/3] net: dsa: lan9303: constify dsa_switch_ops
>>   [PATCH 3/3] net: dsa: mt7530: constify dsa_switch_ops
> 
> For the whole series:
> 
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>

None of these patches apply to net-next, things are const there
already.
