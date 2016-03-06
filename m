From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] bridge: mdb: add support for extended
 router port information
Date: Sun, 6 Mar 2016 12:56:04 -0800
Message-ID: <20160306125604.7978a1d9@xeon-e3>
References: <1457018374-25420-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33960 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbcCFUzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 15:55:51 -0500
Received: by mail-pa0-f51.google.com with SMTP id fy10so65735611pac.1
        for <netdev@vger.kernel.org>; Sun, 06 Mar 2016 12:55:51 -0800 (PST)
In-Reply-To: <1457018374-25420-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  3 Mar 2016 16:19:34 +0100
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> +static int is_temp_mcast_rtr(__u8 type)
>  {
> +	if (type == MDB_RTR_TYPE_TEMP_QUERY || type == MDB_RTR_TYPE_TEMP)
> +		return 1;
> +	else
> +		return 0;
> +}
> +

Minor style issues, why not much simpler:

static bool is_tmp_mcast_rtr(__u8 type)
{
	return (type == MDB_RTR_TYPE_TEMP_QUERY || type == MDB_RTR_TYPE_TEMP);
}
