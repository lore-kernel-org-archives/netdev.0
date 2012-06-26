From: Joe Perches <joe@perches.com>
Subject: Re: [net-next patch] bnx2x: Change bnx2x_tests_str_arr to static
 char
Date: Tue, 26 Jun 2012 07:41:17 -0700
Message-ID: <1340721677.3359.32.camel@joe2Laptop>
References: <1340727063-23870-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
To: Merav Sicron <meravs@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:60470 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752531Ab2FZOlS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2012 10:41:18 -0400
In-Reply-To: <1340727063-23870-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-26 at 19:11 +0300, Merav Sicron wrote:
> This patch changes the definition of bnx2x_tests_str_arr from char to static
> char.
[]
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
[]
> @@ -1600,7 +1600,7 @@ static int bnx2x_set_pauseparam(struct net_device *dev,
>  	return 0;
>  }
>  
> -char *bnx2x_tests_str_arr[BNX2X_NUM_TESTS_SF] = {
> +static char *bnx2x_tests_str_arr[BNX2X_NUM_TESTS_SF] = {
>  	"register_test (offline)    ",
>  	"memory_test (offline)      ",
>  	"int_loopback_test (offline)",

Should probably be const too.
