From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: SysKonnect sk98lin Gigabit lan missing in action from 2.6.10
 on
Date: Fri, 04 Feb 2005 16:07:10 -0500
Message-ID: <4203E3FE.2090806@pobox.com>
References: <42038994.20401@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Netdev <netdev@oss.sgi.com>
To: maxer <maxer@xmission.com>
In-Reply-To: <42038994.20401@xmission.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

maxer wrote:
> What is the status of sk98lin? Do we have to wait until Syskonnect gets 
> their act together
> and write a new driver for 2.6.10?
> 
> Their latest is Oct 2004 and not at all compatible with 2.6.10 and beyond.

I've been telling SysKonnect for _years_ that they need to split up 
their patches, but they still keep sending ever-larger jumbo driver 
update patches.

Stephen Hemminger split up their patch into a bunch of patches, and I 
applied several of those.

Apparently, Stephen also got sick of trying to patch and clean sk98lin, 
so he went and wrote his own "skge" driver.  It's available in my 
netdev-2.6 queue, and should be in the latest -mm.

	Jeff
