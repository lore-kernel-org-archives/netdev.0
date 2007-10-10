From: Jeff Garzik <jeff@garzik.org>
Subject: [ofa-general] Re: [PATCH 1/4] IPoIB: Fix unused variable warning
Date: Tue, 09 Oct 2007 20:47:28 -0400
Message-ID: <470C2120.30608@garzik.org>
References: <OF20E88706.D91FCF10-ON6525736F.003E50CD-6525736F.003E5E6F@in.ibm.com>	<20071009.042441.30182968.davem@davemloft.net>	<ada3awkhwbv.fsf@cisco.com>	<20071009.135145.95506679.davem@davemloft.net>	<adahckzhprc.fsf@cisco.com>
	<adad4vnhpoq.fsf_-_@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	general@lists.openfabrics.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adad4vnhpoq.fsf_-_@cisco.com>
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

Roland Dreier wrote:
> The conversion to use netdevice internal stats left an unused variable
> in ipoib_neigh_free(), since there's no longer any reason to get
> netdev_priv() in order to increment dropped packets.  Delete the
> unused priv variable.
> 
> Signed-off-by: Roland Dreier <rolandd@cisco.com>
> ---
>  drivers/infiniband/ulp/ipoib/ipoib_main.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)

applied 1-4
