From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: Micrel Phy - Is there a way to configure the Phy not to do 802.3x
 flow control?
Date: Thu, 10 Mar 2016 10:07:55 -0500
Message-ID: <56E18DCB.4050702@ti.com>
References: <56D8B83E.7000303@ti.com> <20160303222654.GS15541@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <johan@kernel.org>,
	"open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>,
	"Kwok, WingMan" <w-kwok2@ti.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:48404 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752722AbcCJPIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 10:08:05 -0500
In-Reply-To: <20160303222654.GS15541@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew,

Thanks for your response!

On 03/03/2016 05:26 PM, Andrew Lunn wrote:
> On Thu, Mar 03, 2016 at 05:18:38PM -0500, Murali Karicheri wrote:
>> Hi,
>>
>> We are using Micrel Phy in one of our board and wondering if we can force the
>> Phy to disable flow control at start. I have a 1G ethernet switch connected
>> to Phy and the phy always enable flow control. I would like to configure the
>> phy not to flow control. Is that possible and if yes, what should I do in the
>> my Ethernet driver to tell the Phy not to enable flow control?
> 
> Hi Murali
> 
> Have you played with:
> 
>        ethtool -a|--show-pause devname
> 
>        ethtool -A|--pause devname [autoneg on|off] [rx on|off] [tx on|off]
> 
> Andrew
> 
I will try, but my question is for disabling flow control by default in the
phy when Ethernet driver is initialized. How does the driver tells the phy
to disable tx/rx flow control. Even if phy advertise flow control capability
the Ethernet h/w MAC layer should be capable of doing a Pause. So the driver
needs to have a way to disable tx/rx FC when it starts. How this can be 
achieved? We would like to disable this by default. User will be able to
enable it through ethtool command if it desire to have FC for a specific
use case. Isn't reasonable?  

-- 
Murali Karicheri
Linux Kernel, Keystone
