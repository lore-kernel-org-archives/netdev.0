From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 01/21] [next] qlge: Change to device ID 8000 and
	corresponding flash access.
Date: Fri, 23 Jan 2009 23:28:59 +0000
Message-ID: <1232753339.3005.6.camel@achroite>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org>
	 <1232723799-8620-1-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-driver@qlogic.com
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:50322 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757921AbZAWX3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 18:29:04 -0500
In-Reply-To: <1232723799-8620-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-01-23 at 07:16 -0800, Ron Mercer wrote:
[...]
> diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
> index 16eb9dd..a530f5b 100644
> --- a/drivers/net/qlge/qlge_main.c
> +++ b/drivers/net/qlge/qlge_main.c
[...]
> @@ -657,28 +680,38 @@ static int ql_read_flash_word(struct ql_adapter *qdev, int offset, u32 *data)
>  	if (status)
>  		goto exit;
>  	/* get the data */
> -	*data = ql_read32(qdev, FLASH_DATA);
> +	*data = cpu_to_le32(ql_read32(qdev, FLASH_DATA));
[...]

Should be le32_to_cpu not cpu_to_le32.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

