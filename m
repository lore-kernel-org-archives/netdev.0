From: Balazs Scheidler <bazsi@balabit.hu>
Subject: Re: [NETFILTER] NAT sequence adjustment: Save eight bytes per
	conntrack
Date: Tue, 31 Jan 2006 09:50:52 +0100
Message-ID: <1138697452.5005.9.camel@bzorp.balabit>
References: <20060130232209.GG4603@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20060130232209.GG4603@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-01-31 at 00:22 +0100, Harald Welte wrote:

> ---
> commit 94d3d40c84672b74e59ea5252f61602610e1513e
> tree 63e5ae5174af9f982be6d8d1bbe11e750e4ace32
> parent e3c7a1f99300fbd6de35a40fcd9c4dc1b0fbfee2
> author Harald Welte <laforge@netfilter.org> Fri, 27 Jan 2006 16:03:45 +0100
> committer Harald Welte <laforge@netfilter.org> Fri, 27 Jan 2006 16:03:45 +0100
> 
>  include/linux/netfilter_ipv4/ip_nat.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/netfilter_ipv4/ip_nat.h b/include/linux/netfilter_ipv4/ip_nat.h
> index 41a107d..e9f5ed1 100644
> --- a/include/linux/netfilter_ipv4/ip_nat.h
> +++ b/include/linux/netfilter_ipv4/ip_nat.h
> @@ -23,7 +23,7 @@ struct ip_nat_seq {
>  	 * modification (if any) */
>  	u_int32_t correction_pos;
>  	/* sequence number offset before and after last modification */
> -	int32_t offset_before, offset_after;
> +	int16_t offset_before, offset_after;
>  };

Am I missing something or is it only 4 bytes?

-- 
Bazsi
