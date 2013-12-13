From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v2 9/9] xen-netback: Aggregate TX unmap
 operations
Date: Fri, 13 Dec 2013 15:44:35 +0000
Message-ID: <20131213154435.GP21900@zion.uk.xensource.com>
References: <1386892097-15502-1-git-send-email-zoltan.kiss@citrix.com>
 <1386892097-15502-10-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1386892097-15502-10-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 12, 2013 at 11:48:17PM +0000, Zoltan Kiss wrote:
> Unmapping causes TLB flushing, therefore we should make it in the largest
> possible batches. However we shouldn't starve the guest for too long. So if
> the guest has space for at least two big packets and we don't have at least a
> quarter ring to unmap, delay it for at most 1 milisec.
> 

Is this solution temporary or permanent? If it is permanent would it
make sense to make these parameter tunable?

Wei.
