From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [net-next:master 17/24] DockBook: net/core/skbuff.c:4404:
 warning: No description found for parameter 'mtu'
Date: Sat, 4 Jun 2016 09:19:19 -0300
Message-ID: <27ae121d-e398-6f68-6058-6096b6f25729@gmail.com>
References: <201606040815.Lov0U6ON%fengguang.wu@intel.com>
 <20160603.225702.1041264232859054469.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33707 "EHLO
	mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824AbcFDMT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2016 08:19:27 -0400
Received: by mail-qk0-f195.google.com with SMTP id u63so347701qkh.0
        for <netdev@vger.kernel.org>; Sat, 04 Jun 2016 05:19:27 -0700 (PDT)
In-Reply-To: <20160603.225702.1041264232859054469.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 04-06-2016 02:57, David Miller escreveu:
> From: kbuild test robot <fengguang.wu@intel.com>
> Date: Sat, 4 Jun 2016 08:48:17 +0800
>
>> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
>> head:   330348d94223346f855357fab2517f6c903001c7
>> commit: ae7ef81ef000adeee7a87585b9135ff8a8064acc [17/24] skbuff: introduce skb_gso_validate_mtu
>> reproduce: make htmldocs
>>
>> All warnings (new ones prefixed by >>):
>>
>>    include/linux/skbuff.h:928: warning: No description found for parameter 'sk'
>>    include/net/sock.h:449: warning: No description found for parameter 'sk_padding'
>>    include/net/sock.h:449: warning: No description found for parameter 'sk_rcu'
>>>> net/core/skbuff.c:4404: warning: No description found for parameter 'mtu'
>>    net/core/gen_stats.c:65: warning: No description found for parameter 'padattr'
>>    net/core/gen_stats.c:100: warning: No description found for parameter 'padattr'
>
> Fixed as follows:
>
> ====================
> net: Add docbook description for 'mtu' arg to skb_gso_validate_mtu()
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/core/skbuff.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index b6e0f95..e7ec6d3 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -4399,6 +4399,7 @@ EXPORT_SYMBOL_GPL(skb_gso_transport_seglen);
>   * skb_gso_validate_mtu - Return in case such skb fits a given MTU
>   *
>   * @skb: GSO skb
> + * @mtu: MTU to validate against
>   *
>   * skb_gso_validate_mtu validates if a given skb will fit a wanted MTU
>   * once split.
>

Thanks David.
