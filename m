From: Glen Turner <glen.turner@aarnet.edu.au>
Subject: Re: RFC: PHY Abstraction Layer II
Date: Tue, 28 Jun 2005 16:08:51 +0930
Message-ID: <42C0F07B.8040506@aarnet.edu.au>
References: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com> <20050531105939.7486e071@dxpl.pdx.osdl.net> <92F1428A-0B26-428B-8C06-35C7E5B9EEE3@freescale.com> <20050601144123.2bc11c06@dxpl.pdx.osdl.net> <9A2D608A-D818-455B-96F4-ED42413556C0@freescale.com> <42A360A0.1040902@aarnet.edu.au> <0A9010B9-D24A-4762-8069-F19607ADD416@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, Netdev <netdev@oss.sgi.com>,
        Kumar Gala <kumar.gala@freescale.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <0A9010B9-D24A-4762-8069-F19607ADD416@freescale.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andy Fleming wrote:

> I was thinking that it would be easier for the ethernet driver to do  
> this in the adjust_link() function, since it's going to need to track  
> when these things change, anyway.  But if the general consensus is  that 
> it should be in the generic code, I can see about adding it there.

Hi Andy,

I wasn't at all saying where it should be done -- rather that
it's very useful for networking staff like myself that it is
done *somewhere*.

Without too much knowledge of the code, it would be nice if
it were done in the PHY layer, so that the messages can be
grepped for in logs. If you leave it to drivers there'll
be inconsistent levels of detail and a variety of formats.

>> Also, it would be nice to be able to retrieve PHY data
>> independent of the interface status (eg, to retrieve
>> asset serial numbers, GBIC make/models, etc).
> 
> 
> I'm not sure what you mean, here.  The driver can use phy_read/write  to 
> get/set information anytime it wants.

Is there a user space utility to pull the details from
a GBIC's EEPROM?

Thanks,
Glen

-- 
  Glen Turner         Tel: (08) 8303 3936 or +61 8 8303 3936
  Australia's Academic & Research Network  www.aarnet.edu.au
