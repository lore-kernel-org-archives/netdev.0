From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [IPoIB] Identify multicast packets and fix IGMP breakage V3
Date: Thu, 26 Aug 2010 18:17:52 -0600
Message-ID: <20100827001752.GB24333@obsidianresearch.com>
References: <20100826234342.GA24333@obsidianresearch.com> <7E95F01E94AB484F83061FCFA35B39F89BE276@exil.voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>, rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Or Gerlitz <ogerlitz-smomgflXvOZWk0Htik3J/w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Yossi Etigin <yosefe-smomgflXvOZWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <7E95F01E94AB484F83061FCFA35B39F89BE276-QfUkFaTmzUSUvQqKE/ONIwC/G2K4zDHf@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 27, 2010 at 03:02:54AM +0300, Yossi Etigin wrote:

> Shouldn't struct ib_grh be packed to make this really work?

No idea what the kernel convention for this is. It looks OK to me, in
that no arch I am familiar with will insert padding.

> The code looks a little messy to me anyway... 
> How about using a local var which is a ptr to packed struct ib_grh? The
> compiler will probably eliminate it anyway.

This bike shed is looking pretty well painted already :)

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
