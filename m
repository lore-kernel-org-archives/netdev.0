From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 2.6.12-rc5] tg3: add bcm5752 entry to pci.ids
Date: Fri, 27 May 2005 16:40:21 -0400
Message-ID: <429785B5.6020705@pobox.com>
References: <04132005193844.8474@laptop> <20050421165956.55bdcb14.davem@davemloft.net> <20050527184750.GB11592@tuxdriver.com> <20050527.123037.68041200.davem@davemloft.net> <1117221859.4310.6.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, linville@tuxdriver.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1117221859.4310.6.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> On Fri, 2005-05-27 at 12:30 -0700, David S. Miller wrote:
> 
> 
>>I'll apply this, thanks John.
>>
>>pci.ids needs several updates for tg3 in fact, and it
>>also now needs entries for bnx2 as well.
>>
> 
> 
> The bnx2 IDs are already in, probably from sourceforge. And the tg3 IDs
> look reasonably complete to me.
> 
> So in the future, do we need to patch this file or just let sourceforge
> take care of it?

Honestly, pci.ids is such a non-critical file, unless DaveM disagrees I 
would strongly encourage people to -only- send pci.ids updates to 
sourceforge.

pci.ids is only used in one location -- deprecated /proc/pci -- and will 
be removed in the next year or so, I imagine. Further, pci.ids is 
periodically sync'd en masse from sourceforge into the kernel by janitors.

Users should be using 'lspci' not /proc/pci, and lspci takes it data 
from sourceforge database not the kernel.

	Jeff
