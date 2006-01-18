From: Sean Hefty <mshefty@ichips.intel.com>
Subject: Re: RE: [PATCH 2/5] [RFC] Infiniband: connection
	abstraction
Date: Wed, 18 Jan 2006 10:13:34 -0800
Message-ID: <43CE854E.4060703@ichips.intel.com>
References: <ORSMSX401FRaqbC8wSA0000003e@orsmsx401.amr.corp.intel.com>
	<ORSMSX401FRaqbC8wSA00000040@orsmsx401.amr.corp.intel.com>
	<20060118020342.GB3740@esmail.cup.hp.com>
	<43CE7EDB.7030201@ichips.intel.com>
	<20060118180243.GD6818@esmail.cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Grant Grundler <iod00d@hp.com>
In-Reply-To: <20060118180243.GD6818@esmail.cup.hp.com>
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

Grant Grundler wrote:
>>>Is this code going to get invoked very often?
>>
>>In practice, it would be invoked when matching any listen requests 
>>originating from the CMA (RDMA connection abstraction).
> 
> hrm..I'm not sure how to translate your answer into a workload.
> e.g. which netperf or netpipe test would excercise this alot?
> Or would it take something like MPI or specweb/ttcp?

The code will be invoked at least once for every connection that is established.

>>>e.g something like:
>>>	for (i = 0; i < IB_CM_PRIVATE_DATA_COMPARE_SIZE/sizeof(unsigned 
>>>	long);
>>>									i++)
>>>		((unsigned long *)dst)[i] = ((unsigned long *)src)[i] 
>>>						& ((unsigned long *)mask)[i];
>>
>>Yes - something like this should work.  Thanks.
> 
> 
> Do you need a patch?
> I can submit one but it will be untested.

I will incorporate the change with the next set of updates.  Someone else 
pointed out that I'd need to make sure that there won't be any alignment issues.

- Sean
