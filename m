From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [ofa-general] [PATCH v2] iw_cxgb3: Support "iwarp-only" interfaces
	to avoid 4-tuple conflicts.
Date: Sat, 15 Sep 2007 09:07:06 -0500
Message-ID: <46EBE70A.6040901@opengridcomputing.com>
References: <20070913191617.30937.95960.stgit@dell3.ogc.int>
	<46E99586.90905@ichips.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org,
	linux-kernel@vger.kernel.org
To: Sean Hefty <mshefty@ichips.intel.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46E99586.90905@ichips.intel.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org



Sean Hefty wrote:
>> The iWARP driver must translate all listens on address 0.0.0.0 to the
>> set of rdma-only ip addresses for the device in question.  This prevents
>> incoming connect requests to the TCP ipaddresses from going up the
>> rdma stack.
> 
> I've only given this a high level review at this point, and while the 
> patch looks okay on first pass, is there a way to move some of this 
> functionality to either the rdma_cm or iw_cm?  I don't like the idea of 
> every iwarp driver having to implement address/listen list maintenance. 
>  I may have some ideas after re-examining it.

I think the translating of listen requests from 0.0.0.0->specific 
addresses could be moved to the iwcm...

> 
>> Implementation Details:
> 
> There are a couple of areas that I made a note to look at in more detail 
> (because I didn't understand everything that was happening), but I did 
> have one minor nit - most uses of list_del_init can just be list_del.
> 

Ok.
