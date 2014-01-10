From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] sctp: make sctp_addto_chunk_fixed local
Date: Fri, 10 Jan 2014 23:45:27 +0300
Message-ID: <52D05BE7.9020203@cogentembedded.com>
References: <20140109223111.71e55286@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:52704 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756176AbaAJTpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 14:45:24 -0500
Received: by mail-lb0-f177.google.com with SMTP id z5so1364497lbh.36
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 11:45:23 -0800 (PST)
In-Reply-To: <20140109223111.71e55286@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/10/2014 09:31 AM, Stephen Hemminger wrote:

> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

[...]

> --- a/net/sctp/sm_make_chunk.c	2014-01-09 22:29:51.871663405 -0800
> +++ b/net/sctp/sm_make_chunk.c	2014-01-09 22:29:58.323581984 -0800
> @@ -78,6 +78,8 @@ static int sctp_process_param(struct sct
>   			      gfp_t gfp);
>   static void *sctp_addto_param(struct sctp_chunk *chunk, int len,
>   			      const void *data);
> +static void  *sctp_addto_chunk_fixed(struct sctp_chunk *, int len,

    Sorry for nitpicking but two spaces after 'void' don't align well with the 
previous declaration. Probably can be fixed while applying...

> +				     const void *data);
>
>   /* Control chunk destructor */
>   static void sctp_control_release_owner(struct sk_buff *skb)

WBR, Sergei
