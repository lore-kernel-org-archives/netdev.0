From: Divy Le Ray <divy@chelsio.com>
Subject: [ofa-general] Re: [PATCH 2.6.21] iw_cxgb3 - Add set_tcb_rpl_handler.
Date: Thu, 12 Apr 2007 07:44:19 -0700
Message-ID: <461E45C3.2050400@chelsio.com>
References: <1176382594.9396.1.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	Jeff Garzik <jeff@garzik.org>, linux-kernel <linux-kernel@vger.kernel.org>,
	OpenFabrics General <general@lists.openfabrics.org>
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1176382594.9396.1.camel@stevo-desktop>
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

Steve Wise wrote:
> Hey Roland,
>
> This patch is needed for iw_cxgb3 to handle a change in the cxgb3 driver
> posted by Divy that Jeff recently applied.  If the cxgb3 change is
> destined for 2.6.21, then this change to iw_cxgb3 also needs to go in
> (otherwise we get an error log entry for every rdma connection).  
>
> It was an oversight that this patch didn't really get included in Divy's
> series since the two go together.
>
> See http://marc.info/?l=linux-netdev&m=117617444422260&w=2
>
>
> Thanks,
>
> Steve.
>
>
> ---
>
>
> Add set_tcb_rpl_handler.
>
> The Ethernet Driver no longer handles SET_TCB replies.
>
> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
>   
Acked-by: Divy Le Ray <divy@chelsio.com>
