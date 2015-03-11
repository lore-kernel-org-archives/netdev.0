From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next 1/3] net: Add max rate tx queue attribute
Date: Wed, 11 Mar 2015 11:50:32 -0700
Message-ID: <55008E78.8020607@intel.com>
References: <1426079690-28271-1-git-send-email-ogerlitz@mellanox.com> <1426079690-28271-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Matan Barak <matanb@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:56917 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750820AbbCKSug (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 14:50:36 -0400
In-Reply-To: <1426079690-28271-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/11/2015 06:14 AM, Or Gerlitz wrote:
> From: John Fastabend <john.r.fastabend@intel.com>
> 
> This adds a tx_maxrate attribute to the tx queue sysfs entry allowing
> for max-rate limiting. Along with DCB-ETS and BQL this provides another
> knob to tune queue performance. The limit units are Mbps.
> 
> By default it is disabled. To disable the rate limitation after it
> has been set for a queue, it should be set to zero.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>  include/linux/netdevice.h |    9 ++++++
>  net/core/net-sysfs.c      |   70 +++++++++++++++++++++++++++++++++++++--------
>  2 files changed, 67 insertions(+), 12 deletions(-)

hmm I'm not sure sysfs is entirely the correct interface although it is
convenient. Did you consider porting to netlink? To be honest I can't
remember why I didn't do it netlink to start with. I think at the time
I was more interested in the controller, feedback loop aspect. Basically
I was dynamically managing the rate limiters across NICs from an agent to
try and manage some types of congestion.

.John
