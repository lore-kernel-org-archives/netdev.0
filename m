From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH] drivers/isdn/hardware/mISDN: fix sparse warnings: make
 symbols static
Date: Fri, 13 Feb 2009 11:05:58 +0100
Message-ID: <49954606.9080204@gmail.com>
References: <20090212192810.7401.70271.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hannes Eder <hannes@hanneseder.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.184]:30691 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889AbZBMKGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2009 05:06:03 -0500
In-Reply-To: <20090212192810.7401.70271.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/12/2009 08:28 PM, Hannes Eder wrote:
> diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
> index f0e14df..2bb85c4 100644
> --- a/drivers/isdn/hardware/mISDN/hfcpci.c
> +++ b/drivers/isdn/hardware/mISDN/hfcpci.c
> @@ -56,8 +56,8 @@ static const char *hfcpci_revision = "2.0";
>  static int HFC_cnt;
>  static uint debug;
>  static uint poll, tics;
> -struct timer_list hfc_tl;
> -u32	hfc_jiffies;
> +static struct timer_list hfc_tl;
> +static u32 hfc_jiffies;

Please also fix the hfc_jiffies type (ulong). (As a separate patch.)
