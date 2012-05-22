From: David Daney <david.daney@cavium.com>
Subject: Re: [PATCH 5/5] netdev/phy: Add driver for Cortina cs4321 quad 10G
 PHY.
Date: Tue, 22 May 2012 12:25:50 -0700
Message-ID: <4FBBE83E.9090307@cavium.com>
References: <1337709592-23347-1-git-send-email-ddaney.cavm@gmail.com> <1337709592-23347-6-git-send-email-ddaney.cavm@gmail.com> <20120522185032.GR4038@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Daney <ddaney.cavm@gmail.com>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mips@linux-mips.org" <linux-mips@linux-mips.org>,
	Fleming Andy-AFLEMING <afleming@freescale.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120522185032.GR4038@decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/22/2012 11:50 AM, Ben Hutchings wrote:
> On Tue, May 22, 2012 at 10:59:52AM -0700, David Daney wrote:
> [...]
>> --- /dev/null
>> +++ b/drivers/net/phy/cs4321-ucode.h
>> @@ -0,0 +1,4378 @@
>> +/*
>> + *    Copyright (C) 2011 by Cortina Systems, Inc.
>> + *
>> + *    This program is free software; you can redistribute it and/or modify
>> + *    it under the terms of the GNU General Public License as published by
>> + *    the Free Software Foundation; either version 2 of the License, or
>> + *    (at your option) any later version.
>> + *
>> + *    This program is distributed in the hope that it will be useful,
>> + *    but WITHOUT ANY WARRANTY; without even the implied warranty of
>> + *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>> + *    GNU General Public License for more details.
>> + *
>> + */
> [...]
>
> So where's the real source code for it?

I wish I knew.  The vendor released the array of random numbers as GPL 
to us. :-(

>
> If you won't (or can't) provide source code for the microcode then it
> should instead be submitted to linux-firmware with a binary
> redistribution licence, and the driver should load it with
> request_firmware().

I will attempt to do that.

The .c file contains plenty of other pseudo-random numbers, but those 
cannot really be considered 'firmware'

David Daney
