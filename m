From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] phy: remove irq param to fix crash in fixed_phy_add()
Date: Tue, 17 May 2016 11:27:12 -0700
Message-ID: <573B6280.3030405@gmail.com>
References: <1463397356-5656-1-git-send-email-rabin.vincent@axis.com>
 <20160517.142034.611823602956859056.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, netdev@vger.kernel.org,
        linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org,
        devicetree@vger.kernel.org, rabinv@axis.com
To: David Miller <davem@davemloft.net>, rabin.vincent@axis.com
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20160517.142034.611823602956859056.davem@davemloft.net>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On 05/17/2016 11:20 AM, David Miller wrote:
> From: Rabin Vincent <rabin.vincent@axis.com>
> Date: Mon, 16 May 2016 13:15:56 +0200
> 
>> From: Rabin Vincent <rabinv@axis.com>
>>
>> Since e7f4dc3536a ("mdio: Move allocation of interrupts into core"),
>> platforms which call fixed_phy_add() before fixed_mdio_bus_init() is
>> called (for example, because the platform code and the fixed_phy driver
>> use the same initcall level) crash in fixed_phy_add() since the
>> ->mii_bus is not allocated.
>>
>> Also since e7f4dc3536a, these interrupts are initalized to polling by
>> default.  All callers of both fixed_phy_register() and fixed_phy_add()
>> pass PHY_POLL for the irq argument, so we can fix these crashes by
>> simply removing the irq parameter, since the default is correct for all
>> users.
>>
>> Fixes: e7f4dc3536a400 ("mdio: Move allocation of interrupts into core")
>> Signed-off-by: Rabin Vincent <rabinv@axis.com>
> 
> Applied.

David, there was a v2 sent just earlier this morning here:

http://patchwork.ozlabs.org/patch/622967/

which was appropriately marked with Changes Requested, so why would we
apply v1?
-- 
Florian
