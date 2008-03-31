From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 6/8] e1000e: convert ndev_ printks
	to	something smaller
Date: Mon, 31 Mar 2008 11:36:23 -0700
Message-ID: <47F12F27.802@intel.com>
References: <20080328161503.6562.44329.stgit@localhost.localdomain>
	<20080328161531.6562.8515.stgit@localhost.localdomain>
	<47EDA38F.6080301@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-reply-to: <47EDA38F.6080301@garzik.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Auke Kok wrote:
>> From: Bruce Allan <bruce.w.allan@intel.com>
>>
>> The ndev_* printk's are too lenghty and we don't need to specify
>> the adapter/netdev struct at all, making this a lot more readable.
>>
>> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> ---
>>
>>  drivers/net/e1000e/e1000.h   |   27 ++++----
>>  drivers/net/e1000e/ethtool.c |   38 +++++------
>>  drivers/net/e1000e/netdev.c  |  148 +++++++++++++++++++-----------------------
>>  drivers/net/e1000e/param.c   |   31 +++------
>>  4 files changed, 108 insertions(+), 136 deletions(-)
> 
> This stuff should just be removed.
> 
> Either the code should be outputting "ethX: blahblah" via printk(), or 
> the code should be outputting the standard dev_printk() prefix [driver 
> name, PCI device info].
> 
> Also, it is recommended to use the NETIF_MSG_xxx bits to permit 
> fine-grained control over which messages are output, on a per-port basis 
> (controlled via ethtool).  grep around for 'msg_enable'

yes and I even tried pushing for a generic netdev printk that incorporates the
msg_enable bits properly

I also got absolutely unwelcome responses to that, if not none :)

once we get such a thing, we can incorporate this into e1000 with this patch by
changing 2 lines. so I think this patch is still a good thing, and it certainly
removes a lot of wrapped lines.

Auke


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
