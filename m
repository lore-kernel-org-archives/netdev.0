From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH nft] src: add netdev family support
Date: Tue, 26 May 2015 18:52:04 +0200
Message-ID: <20150526165204.GA13360@acer.localdomain>
References: <1432558004-13481-1-git-send-email-pablo@netfilter.org>
 <1432558004-13481-6-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1432558004-13481-6-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25.05, Pablo Neira Ayuso wrote:
> diff --git a/include/rule.h b/include/rule.h
> index 97959f7..06ec2ff 100644
> --- a/include/rule.h
> +++ b/include/rule.h
> @@ -72,6 +72,7 @@ enum table_flags {
>   *
>   * @list:	list node
>   * @handle:	table handle
> + * @dev:	network device name (only for netdev family)
>   * @location:	location the table was defined at
>   * @chains:	chains contained in the table
>   * @sets:	sets contained in the table
> @@ -80,6 +81,7 @@ enum table_flags {
>  struct table {
>  	struct list_head	list;
>  	struct handle		handle;
> +	const char		*dev;

I think this logically belongs into struct handle itself.
