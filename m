From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH v3 17/20] net/xen-netfront: Make it running
 on 64KB page granularity
Date: Thu, 20 Aug 2015 11:03:50 +0100
Message-ID: <55D5A606.7020701@citrix.com>
References: <1438966019-19322-1-git-send-email-julien.grall@citrix.com>
 <1438966019-19322-18-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <netdev@vger.kernel.org>,
	<stefano.stabellini@eu.citrix.com>, <linux-kernel@vger.kernel.org>,
	"David Vrabel" <david.vrabel@citrix.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<linux-arm-kernel@lists.infradead.org>
To: Julien Grall <julien.grall@citrix.com>,
	<xen-devel@lists.xenproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438966019-19322-18-git-send-email-julien.grall@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/08/15 17:46, Julien Grall wrote:
> The PV network protocol is using 4KB page granularity. The goal of this
> patch is to allow a Linux using 64KB page granularity using network
> device on a non-modified Xen.
> 
> It's only necessary to adapt the ring size and break skb data in small
> chunk of 4KB. The rest of the code is relying on the grant table code.
> 
> Note that we allocate a Linux page for each rx skb but only the first
> 4KB is used. We may improve the memory usage by extending the size of
> the rx skb.

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

David
