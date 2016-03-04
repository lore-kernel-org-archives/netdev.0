From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 4/4] ethtool.h: define INT_MAX for userland
Date: Fri, 4 Mar 2016 14:10:12 +0100
Message-ID: <56D98934.4050409@cumulusnetworks.com>
References: <20160303.170804.2300821465150459193.davem@davemloft.net>
 <1457088739-1065-1-git-send-email-nicolas.dichtel@6wind.com>
 <1457088739-1065-5-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@decadent.org.uk,
	Karen Xie <kxie@chelsio.com>, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Airlie <airlied@linux.ie>,
	dri-devel@lists.freedesktop.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457088739-1065-5-git-send-email-nicolas.dichtel@6wind.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/04/2016 11:52 AM, Nicolas Dichtel wrote:
> INT_MAX needs limits.h in userland.
> When ethtool.h is included by a userland app, we got the following error:
> 
> .../usr/include/linux/ethtool.h: In function 'ethtool_validate_speed':
> .../usr/include/linux/ethtool.h:1471:18: error: 'INT_MAX' undeclared (first use in this function)
>   return speed <= INT_MAX || speed == SPEED_UNKNOWN
>                   ^
> 
> Fixes: e02564ee334a ("ethtool: make validate_speed accept all speeds between 0 and INT_MAX")
> CC: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  include/uapi/linux/ethtool.h | 4 ++++
>  1 file changed, 4 insertions(+)
> 

Thanks!

Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
