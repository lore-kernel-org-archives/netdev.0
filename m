From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6] eepro100: remove ID for 82556
Date: Sat, 19 Feb 2005 00:03:31 -0500
Message-ID: <4216C8A3.4020303@pobox.com>
References: <1107285106.3366.106.camel@sfeldma-mobl.dsl-verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: sfeldma@pobox.com
In-Reply-To: <1107285106.3366.106.camel@sfeldma-mobl.dsl-verizon.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Scott Feldman wrote:
> 82556 support doesn't work with eepro100, so this removes the ID
> (0x1228) for 82556.  See this thread for more info:
> 
> http://marc.theaimsgroup.com/?l=linux-kernel&m=110726223221165&w=2
> 
> Signed-off-by: Scott Feldman <sfeldma@pobox.com>

I see the thread, but I still worry about removing the id in your patch, 
since the poster in the thread says that they had to -add- an ID to both 
e100 and eepro100 in order to perform their test.

Has anyone with this PCI ID actually confirmed that eepro100 does not 
work for them?

	Jeff
