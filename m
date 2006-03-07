From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] IPoIB: Fix build now that destructor
	is in neigh_params
Date: Tue, 07 Mar 2006 14:53:50 -0800 (PST)
Message-ID: <20060307.145350.77989471.davem@davemloft.net>
References: <adazmlmmy7v.fsf@cisco.com> <20060306211630.0df79464.akpm@osdl.org>
	<adawtf6rrh7.fsf_-_@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: rdreier@cisco.com
In-Reply-To: <adawtf6rrh7.fsf_-_@cisco.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 07 Mar 2006 11:21:08 -0800

> Dave, here's an incremental patch that fixes the IPoIB build (which is
> broken in net-2.6.17 because of my screw-up, which left out the chunk
> below).  I'll also send a full patch that can replace the "Move
> destructor from neigh->ops to neigh_params" patch if you'd rather
> replace it in your tree.
> 
> Thanks, and sorry about the screw-up.

Why not just put this into your -ipoib patch set in -mm?
The change was for IPOIB's sake anyways...
