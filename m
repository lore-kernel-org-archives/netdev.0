From: Andy Fleming <afleming@freescale.com>
Subject: Re: [RFC] Patch to Abstract Ethernet PHY support (using driver model)
Date: Thu, 13 Jan 2005 12:22:20 -0600
Message-ID: <103A69BE-6590-11D9-8D70-000393C30512@freescale.com>
References: <FC6D9B81-5514-11D9-8D51-000393C30512@freescale.com> <A3A281FF-5525-11D9-80ED-000393C30512@freescale.com> <D3652CF8-6571-11D9-821C-000393DBC2E8@freescale.com> <20050113090250.15444e09@dxpl.pdx.osdl.net>
Mime-Version: 1.0 (Apple Message framework v619)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kumar Gala <kumar.gala@freescale.com>, Jeff Garzik <jgarzik@pobox.com>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050113090250.15444e09@dxpl.pdx.osdl.net>
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Jan 13, 2005, at 11:02, Stephen Hemminger wrote:
>> On Dec 23, 2004, at 3:00 PM, Andy Fleming wrote:
>>
>>> It has been suggested that I split the patch into 2 parts: gianfar
>>> specific stuff, and PHY specific stuff.
>>>
>>> Here is the result:
>>> <gfar_12232004.patch><phy_12232004.patch><ATT229010.txt>
>>
>
> It would be more valuable if there were cases where multiple different 
> boards that
> use the same type of PHY chip were supported. Even better if it could 
> subsume the existing
> MII code. Don't know enough about all the different flavors of 
> hardware to know what
> combinations exist but it looks like there are different boards that 
> have the same
> PHY chips. It looks like the FreeBSD tries to abstract this.

I'm not clear what you mean here.  The whole point of the code is to 
allow different boards which use the same PHY chip to use the same 
code.  The only code that would be different is code that is specific 
to the board.  Does this code not fulfill that requirement?

Andy Fleming
Open Source Team
Freescale Semiconductor, Inc
