From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH] net: Convert to using %pOF instead of full_name
Date: Wed, 19 Jul 2017 10:09:13 -0500
Message-ID: <CAL_JsqJbEq0_yQ-T8-SGTQbRRxHs-MMCuBrK6d8_2jGQ_-7QkA@mail.gmail.com>
References: <20170718214339.7774-39-robh@kernel.org> <20170718.145146.1983238254018568174.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Madalin Bucur <madalin.bucur@nxp.com>,
        Douglas Miller <dougmill@linux.vnet.ibm.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Michal Simek <michal.simek@xilinx.com>,
        Soren Brinkmann <soren.brinkmann@xilinx.com>,
        netdev <netdev@vger.kernel.org>,
        linux-omap <linux-omap@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170718.145146.1983238254018568174.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 18, 2017 at 4:51 PM, David Miller <davem@davemloft.net> wrote:
> From: Rob Herring <robh@kernel.org>
> Date: Tue, 18 Jul 2017 16:43:19 -0500
>
>> Now that we have a custom printf format specifier, convert users of
>> full_name to use %pOF instead. This is preparation to remove storing
>> of the full path string for each node.
>>
>> Signed-off-by: Rob Herring <robh@kernel.org>
>
> Acked-by: David S. Miller <davem@davemloft.net>

The dependency went into 4.13. You can take this thru netdev.

Rob
