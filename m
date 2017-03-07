From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fjes: Do not load fjes driver if system does not have
 extended socket device.
Date: Tue, 07 Mar 2017 13:44:40 -0800 (PST)
Message-ID: <20170307.134440.1909011889217005504.davem@davemloft.net>
References: <fb537059-35b3-3dce-23fb-9a59e8f6926a@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, izumi.taku@jp.fujitsu.com
To: yasu.isimatu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38164 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751302AbdCGWmn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 17:42:43 -0500
In-Reply-To: <fb537059-35b3-3dce-23fb-9a59e8f6926a@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Date: Thu, 2 Mar 2017 11:56:44 -0500

> +
>  /* fjes_init_module - Driver Registration Routine */
>  static int __init fjes_init_module(void)
>  {
>  	int result;
> +	bool found = false;
> +

Please order local variable declarations from longest to shortest
line.

Thanks.
