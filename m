From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] irqchip/renesas-irqc: Postpone driver initialization
Date: Wed, 9 Nov 2016 11:17:05 -0800
Message-ID: <3dface9b-7602-b1f2-0dd6-37b444ac42e3@gmail.com>
References: <1478633747-26878-1-git-send-email-geert+renesas@glider.be>
 <216fe100-556b-7f83-39b0-4cf54c1fa35c@gmail.com>
 <CAMuHMdWkXsAuRpbTWGw9Wp4m2M38zRAd8OpPpA-sCDb7Xb7skw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Geert Uytterhoeven <geert+renesas@glider.be>,
        Thomas Gleixner <tglx@linutronix.de>,
        Jason Cooper <jason@lakedaemon.net>,
        Marc Zyngier <marc.zyngier@arm.com>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdWkXsAuRpbTWGw9Wp4m2M38zRAd8OpPpA-sCDb7Xb7skw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/08/2016 11:50 AM, Geert Uytterhoeven wrote:
> Hi Florian,
> 
> On Tue, Nov 8, 2016 at 8:42 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> On 11/08/2016 11:35 AM, Geert Uytterhoeven wrote:
>>> Currently the renesas-irqc driver uses postcore_initcall().
>>>
>>> However, the new CPG/MSSR driver uses subsys_initcall(). Hence the
>>> IRQC's probe will be deferred, which causes the Micrel Ethernet PHY to
>>> not find its interrupt on R-Car Gen2 and RZ/G, as the of_mdio subsystem
>>> does not support deferred probe yet.
>>
>> Is not that the more correct fix to implement though?
> 
> Sure it is. But nothing has happened since this was reported ca. 1 year ago.
> Cfr. "of_mdiobus_register_phy() and deferred probe"
> https://lkml.org/lkml/2015/10/22/377
> 
> My MDIO foo is not that strong...

Let me try to cook something here which may require
of_mdiobus_register_phy(), are you okay testing patches?
-- 
Florian
