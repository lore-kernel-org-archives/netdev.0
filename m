From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH v2 1/2] net: phy: Fix PHY AN done state machine for
 interrupt driven PHYs
Date: Mon, 27 Mar 2017 14:50:30 +0300
Message-ID: <587458e9-7287-2036-50a9-00c009a7f02c@ti.com>
References: <1490180524-28675-1-git-send-email-rogerq@ti.com>
 <1490180524-28675-2-git-send-email-rogerq@ti.com>
 <fb34f546-f7a7-f09a-b301-af3fdc1709c0@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <andrew@lunn.ch>, <davem@davemloft.net>, <kyle.roeschley@ni.com>,
        <nsekhar@ti.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        "stable # v4 . 9+" <stable@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <fb34f546-f7a7-f09a-b301-af3fdc1709c0@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23/03/17 11:52, Sergei Shtylyov wrote:
> Hello!
> 
> On 3/22/2017 2:02 PM, Roger Quadros wrote:
> 
>> he ethernet link on an interrupt driven PHY was not coming up if the
> 
>    s/he/The/?
> 
>> ethernet cable was plugged before the ethernet interface was brought up.
> 
>    Also, my spell checker trips on "ethernet", perhaps should be capitalized?

Thanks. I'll fix both issues.

> 
>> The PHY state machine seems to be stuck from RUNNING to AN state
>> with no new interrupts from the PHY. So it doesn't know when the
>> PHY Auto-negotiation has been completed and doesn't transition to RUNNING
>> state with ANEG done thus netif_carrier_on() is never called.
>>
>> NOTE: genphy_config_aneg() will not restart PHY Auto-negotiation of
>> advertisement parameters didn't change.
>>
>> Fix this by scheduling the PHY state machine in phy_start_aneg().
>>
>> Fixes: 3c293f4e08b5 ("net: phy: Trigger state machine on state change and not polling.")
>> Cc: stable <stable@vger.kernel.org> # v4.9+
>> Signed-off-by: Roger Quadros <rogerq@ti.com>
> [...]
> 
> MBR, Sergei
> 

cheers,
-roger
