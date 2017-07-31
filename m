From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH net-next 0/2] Refactor lan9303_xxx_packet_processing
Date: Mon, 31 Jul 2017 15:32:15 +0200
Message-ID: <7885564f-2e67-c034-20e6-0377101ff4a7@egil-hjelmeland.no>
References: <20170731113355.4284-1-privat@egil-hjelmeland.no>
 <20170731132236.GB24562@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@pengutronix.de
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170731132236.GB24562@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31. juli 2017 15:22, Andrew Lunn wrote:
> On Mon, Jul 31, 2017 at 01:33:53PM +0200, Egil Hjelmeland wrote:
>> First patch:
>> Change lan9303_enable_packet_processing,
>> lan9303_disable_packet_processing():
>> Pass port number (0,1,2) as parameter instead of port offset.
>> Plus replaced a constant 0x400 with LAN9303_SWITCH_PORT_REG()
> 
> Hi Egil
> 
> The cover note and the commit message should concentrate on the Why,
> not the What. I can see the What by reading the patch.
> 
> Why do you want to pass port numbers?
> 
Because other functions in the module pass port numbers. And to enable
the simplifications.

> Note that for netdev, the cover note also ends up in git as part of
> the history.
> 

OK, I did not know that netdev does that.

>     Andrew
> 
