From: Andy Fleming <afleming@freescale.com>
Subject: Re: RFC: PHY Abstraction Layer II
Date: Thu, 9 Jun 2005 16:32:18 -0500
Message-ID: <0A9010B9-D24A-4762-8069-F19607ADD416@freescale.com>
References: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com> <20050531105939.7486e071@dxpl.pdx.osdl.net> <92F1428A-0B26-428B-8C06-35C7E5B9EEE3@freescale.com> <20050601144123.2bc11c06@dxpl.pdx.osdl.net> <9A2D608A-D818-455B-96F4-ED42413556C0@freescale.com> <42A360A0.1040902@aarnet.edu.au>
Mime-Version: 1.0 (Apple Message framework v730)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, Netdev <netdev@oss.sgi.com>,
        Kumar Gala <kumar.gala@freescale.com>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <42A360A0.1040902@aarnet.edu.au>
To: Glen Turner <glen.turner@aarnet.edu.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Jun 5, 2005, at 15:29, Glen Turner wrote:

>
> Operationally, it would be very useful if the PHY printed
> the physical interface detail when detected (1000Base-LX,
> etc).

I was thinking that it would be easier for the ethernet driver to do  
this in the adjust_link() function, since it's going to need to track  
when these things change, anyway.  But if the general consensus is  
that it should be in the generic code, I can see about adding it there.

>
> Also, it would be nice to be able to retrieve PHY data
> independent of the interface status (eg, to retrieve
> asset serial numbers, GBIC make/models, etc).

I'm not sure what you mean, here.  The driver can use phy_read/write  
to get/set information anytime it wants.

Andy Fleming
