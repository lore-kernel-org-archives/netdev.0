From: Grant Grundler <iod00d@hp.com>
Subject: Re: RE: [PATCH 2/5] [RFC] Infiniband: connection
	abstraction
Date: Wed, 18 Jan 2006 10:02:43 -0800
Message-ID: <20060118180243.GD6818@esmail.cup.hp.com>
References: <ORSMSX401FRaqbC8wSA0000003e@orsmsx401.amr.corp.intel.com>
	<ORSMSX401FRaqbC8wSA00000040@orsmsx401.amr.corp.intel.com>
	<20060118020342.GB3740@esmail.cup.hp.com>
	<43CE7EDB.7030201@ichips.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Sean Hefty <mshefty@ichips.intel.com>
Content-Disposition: inline
In-Reply-To: <43CE7EDB.7030201@ichips.intel.com>
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

On Wed, Jan 18, 2006 at 09:46:03AM -0800, Sean Hefty wrote:
> Grant Grundler wrote:
> >>+static void cm_mask_compare_data(u8 *dst, u8 *src, u8 *mask)
...
> >Is this code going to get invoked very often?
> 
> In practice, it would be invoked when matching any listen requests 
> originating from the CMA (RDMA connection abstraction).

hrm..I'm not sure how to translate your answer into a workload.
e.g. which netperf or netpipe test would excercise this alot?
Or would it take something like MPI or specweb/ttcp?

> >If so, can the mask operation use a "native" size since
> >IB_CM_PRIVATE_DATA_COMPARE_SIZE is hard coded to 64 byte?
> >
> >e.g something like:
> >	for (i = 0; i < IB_CM_PRIVATE_DATA_COMPARE_SIZE/sizeof(unsigned 
> >	long);
> >									i++)
> >		((unsigned long *)dst)[i] = ((unsigned long *)src)[i] 
> >						& ((unsigned long *)mask)[i];
> 
> Yes - something like this should work.  Thanks.

Do you need a patch?
I can submit one but it will be untested.

thanks,
grant
