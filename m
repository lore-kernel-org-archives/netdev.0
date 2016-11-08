From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] irqchip/renesas-irqc: Postpone driver initialization
Date: Tue, 8 Nov 2016 11:42:21 -0800
Message-ID: <216fe100-556b-7f83-39b0-4cf54c1fa35c@gmail.com>
References: <1478633747-26878-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>,
        linux-renesas-soc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>,
        Thomas Gleixner <tglx@linutronix.de>,
        Jason Cooper <jason@lakedaemon.net>,
        Marc Zyngier <marc.zyngier@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478633747-26878-1-git-send-email-geert+renesas@glider.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/08/2016 11:35 AM, Geert Uytterhoeven wrote:
> Currently the renesas-irqc driver uses postcore_initcall().
> 
> However, the new CPG/MSSR driver uses subsys_initcall(). Hence the
> IRQC's probe will be deferred, which causes the Micrel Ethernet PHY to
> not find its interrupt on R-Car Gen2 and RZ/G, as the of_mdio subsystem
> does not support deferred probe yet.

Is not that the more correct fix to implement though?
-- 
Florian
