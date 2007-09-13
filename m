From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [ofa-general] InfiniBand/RDMA merge plans for 2.6.24
Date: Thu, 13 Sep 2007 13:59:21 -0500
Message-ID: <46E98889.1080706@opengridcomputing.com>
References: <adahclymos8.fsf@cisco.com>
	<46E97BB0.9030106@opengridcomputing.com>
	<46E987E0.2010605@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	linux-kernel@vger.kernel.org, general@lists.openfabrics.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46E987E0.2010605@garzik.org>
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



Jeff Garzik wrote:
> Steve Wise wrote:
>> I was about to post v2 of my patch to avoid port space collisions with 
>> the native stack.  Can we get that 2.6.24?  It is high priority IMO. 
>> I've tried to solicit review on it, but I think folks are reluctant... 
>> ;-)
> 
> Well, if it involves /sharing/ port space with the native stack, i.e. 
> where port 1234 is IB but 1235 is Linux, pretty much all the networking 
> devs have NAK'd that approach AFAICS.
> 

Jeff, I posted a fix that doesn't do this.  No port sharing.  The iwarp 
device will use its own ip address and subnet to avoid collisions.  You 
should review the patch when I post v2.

Thanks,

Steve.
