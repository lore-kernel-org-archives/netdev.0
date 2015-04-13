From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 3/4] cxgb4: add DDP support for FCoE target
Date: Mon, 13 Apr 2015 13:12:59 -0400 (EDT)
Message-ID: <20150413.131259.1507649278753208323.davem@davemloft.net>
References: <cover.1428930614.git.varun@chelsio.com>
	<cover.1428930614.git.varun@chelsio.com>
	<a8d335d453e84d5cf2ca7826e6de24eba96af253.1428930614.git.varun@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-rdma@vger.kernel.org, JBottomley@parallels.com,
	roland@purestorage.com, leedom@chelsio.com, anish@chelsio.com,
	hariprasad@chelsio.com, swise@opengridcomputing.com,
	kxie@chelsio.com, praveenm@chelsio.com, kumaras@chelsio.com
To: varun@chelsio.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <a8d335d453e84d5cf2ca7826e6de24eba96af253.1428930614.git.varun@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Varun Prakash <varun@chelsio.com>
Date: Mon, 13 Apr 2015 19:34:25 +0530

> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.c
> index 6c8a62e..f78d632 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.c
...
> + */
> +static inline unsigned int pages2ppods(unsigned int pages)
> +{
> +	return (pages + PPOD_PAGES - 1) / PPOD_PAGES +

Please do not ever use inline in foo.c file function definitions.  Let
the compiler decide on it's own.

Thanks.
