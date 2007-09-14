From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [ofa-general] InfiniBand/RDMA merge plans for 2.6.24
Date: Fri, 14 Sep 2007 16:55:38 +0400
Message-ID: <20070914125536.GF18517@2ka.mipt.ru>
References: <adahclymos8.fsf@cisco.com>
	<46E97BB0.9030106@opengridcomputing.com>
	<46E987E0.2010605@garzik.org>
	<46E98889.1080706@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	general@lists.openfabrics.org, Jeff Garzik <jeff@garzik.org>,
	linux-kernel@vger.kernel.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <46E98889.1080706@opengridcomputing.com>
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

On Thu, Sep 13, 2007 at 01:59:21PM -0500, Steve Wise (swise@opengridcomputing.com) wrote:
> >Well, if it involves /sharing/ port space with the native stack, i.e. 
> >where port 1234 is IB but 1235 is Linux, pretty much all the networking 
> >devs have NAK'd that approach AFAICS.
> 
> Jeff, I posted a fix that doesn't do this.  No port sharing.  The iwarp 
> device will use its own ip address and subnet to avoid collisions.  You 
> should review the patch when I post v2.

Could you please resend it, since I missed it in netdev@.

-- 
	Evgeniy Polyakov
