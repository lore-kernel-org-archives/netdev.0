From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [ofa-general] InfiniBand/RDMA merge plans for 2.6.24
Date: Fri, 14 Sep 2007 14:09:46 -0700
Message-ID: <1189804186.9540.173.camel@dell>
References: <adahclymos8.fsf@cisco.com>
	<46E97BB0.9030106@opengridcomputing.com> <adaps0ml18e.fsf@cisco.com>
	<1189724358.9540.113.camel@dell> <adaveadjk5i.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lusinsky@broadcom.com, general@lists.openfabrics.org, talm@broadcom.com,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	anilgv@broadcom.com, uri@broadcom.com
To: "Roland Dreier" <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adaveadjk5i.fsf@cisco.com>
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

On Fri, 2007-09-14 at 09:18 -0700, Roland Dreier wrote:

> However, do you have any plans to support iSCSI offload for targets?
> Also, looking at the first CNIC patch, I can't help but notice that
> you seem to have at least some support for iWARP there.  How does the
> CNIC look?  Does it share the same interface/addresses as the
> non-offload NIC, or does it create a completely separate netdevice?

We will support iWARP in the future and it should be similar to the way
we do iSCSI - using the same interface/addresses as the bnx2 NIC.

> 
> I want to make sure that whatever solution we come up with for cxgb3
> doesn't cause problems for you.  And of course if you have a better
> idea than what Steve has come up with, that would be great :)
> 

We are looking at these discussions with great interest.  If we have any
new ideas, we'll definitely let everyone know.  Thanks.
