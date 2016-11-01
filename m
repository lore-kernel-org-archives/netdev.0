From: Scott Branden <scott.branden@broadcom.com>
Subject: Re: [PATCH v4 2/7] Documentation: devicetree: add PHY lane swap
 binding
Date: Tue, 1 Nov 2016 14:01:34 -0700
Message-ID: <f56145b6-adb6-186b-0b75-45a9f3a6c58e@broadcom.com>
References: <1478030682-27012-1-git-send-email-jon.mason@broadcom.com>
 <1478030682-27012-3-git-send-email-jon.mason@broadcom.com>
 <20161101204826.GA21010@lunn.ch> <20161101205913.GA27191@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        devicetree@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com, rafal@milecki.pl,
        linux-arm-kernel@lists.infradead.org
To: Jon Mason <jon.mason@broadcom.com>, Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161101205913.GA27191@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 16-11-01 01:59 PM, Jon Mason wrote:
> On Tue, Nov 01, 2016 at 09:48:26PM +0100, Andrew Lunn wrote:
>>> +- enet-phy-lane-swap: If set, indicates the PHY device requires swapping the
>>> +  TX/RX lanes to function properly.
>>
>> Is 'requires' the right word here? The PHY performs the actual swap of
>> the Tx/Rx lanes.
>
> What I'm trying to say here is that without the lane swapping, the PHY
> will not function properly.  Thus, those PHYs require this parameter
> to work.  I am open to suggestions to reword the sentence to make it
> clearer.
If set, indicates the PHY will swap the TX/RX lanes to compensate for 
the board being designed with the lanes swapped.
>
> Thanks,
> Jon
>
>>
>>     Andrew
