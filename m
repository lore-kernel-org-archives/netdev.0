From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ieee80211 subsystem
Date: Fri, 04 Feb 2005 17:48:24 -0500
Message-ID: <4203FBB8.7000507@pobox.com>
References: <4203C32A.70402@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: James Ketrenos <jketreno@linux.intel.com>
In-Reply-To: <4203C32A.70402@linux.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

James Ketrenos wrote:
> Attached is the patch against 2.6.11-rc3-mm1 that adds the ieee80211 
> subsystem used by the ipw2100 and ipw2200 projects.
> 
> I'll be sending out the patches for ipw2100-1.0.0 and ipw2200-1.0.0 that 
> use thist stack to the list on Monday.
> 
> In terms of what the stack currently does:
> 
> * HW independent -- it only knows about 802.11 data and structures
> * Performs an 802.3 <-> 802.11 transform for data Tx/Rx
> * Host based support for fragmentation, WEP, and WPA using the kernel's 
> crypto functions
> * Beacon and probe response collection and parsing
> * Default implementation of some of the WE handlers that can be managed 
> without hardware knowledge
> 
> We are working to merge in Dave Miller's p80211 code into the ieee80211 
> subsystem so that it hooks into the kernel as a true network layer as 
> opposed to a mutated offspring of ethernet.
> Once that is done, hopefully the skb to txb code can be reworked and 
> 802.11 fragments can be treated either as normal skbs, or skbs can be 
> modified to directly support them (ideally so that encrypted 802.11 
> frames in support of IP packets can be cached by the stack instead of 
> having to be re-encrypted on TCP retries)

All this sounds great.  I (and others) will be reviewing, and hope to 
get this into netdev-2.6 very soon.

Thanks much,

	Jeff
