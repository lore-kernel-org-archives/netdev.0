From: Roland Dreier <rolandd@cisco.com>
Subject: Re: Re: [PATCH] netdevice.h: Add RDMA private
	pointer to the net_device structure
Date: Mon, 03 Oct 2005 14:30:30 -0700
Message-ID: <52br269tl5.fsf@cisco.com>
References: <1128365323.4397.38.camel@hal.voltaire.com>
	<20051003135407.072aaff6@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: openib-general@openib.org, netdev@vger.kernel.org
Return-path: <openib-general-bounces@openib.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20051003135407.072aaff6@dxpl.pdx.osdl.net> (Stephen
	Hemminger's message of "Mon, 3 Oct 2005 13:54:07 -0700")
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

    Stephen> Who is going to use it? Is RDMA being submitted for code
    Stephen> review?

I agree that we should hold off on this until there's an in-tree user.
However, just as a clarification, we're trying to move from "ib" to
"rdma" nomenclature as we try to make the existing kernel InfiniBand
layer a more generic layer than can support both IB and iWARP.  So new
code should use "rdma" names.

 - R.
