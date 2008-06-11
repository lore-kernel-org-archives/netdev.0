From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] ixgbe: add LRO support
Date: Wed, 11 Jun 2008 11:16:29 +0100
Message-ID: <20080611101628.GQ11300@solarflare.com>
References: <20080609225658.1219.89600.stgit@localhost.localdomain>
	<20080609225722.1219.51519.stgit@localhost.localdomain>
	<20080609232627.GM11300@solarflare.com>
	<7991c5480806101233u66840348s5a79164e396d0db5@mail.gmail.com>
	<7991c5480806101247h586993a1o31e136484e30bc8f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>, jeff@garzik.org
To: Malli <mchilakala@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <7991c5480806101247h586993a1o31e136484e30bc8f@mail.gmail.com>
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

Malli wrote:
> Forwarding my reply. It got rejected from netdev list, as it was sent in HTML
> 
> Thanks for your feedback Ben. I'll update the patch with ethtool get
> and set flags. But in packet split mode we still wouldn't want to
> limit this with MAX_SKB_FRAGS because we don't actually add the frags
> to the previous packet.  They just chain them together using the
> frag_list and next pointers in the skb. Let me know if it still
> doesn't address your concern in max aggregation.

Yes, I understood that.  I wasn't sure whether MAX_SKB_FRAGS was also meant
to be a limit on the frag_list.  The comment above its definition implies
quite strongly that it isn't, so there's no problem.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
