From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/3] sch_netem: return errcode before setting
 params
Date: Thu, 23 Jan 2014 09:25:03 -0800
Message-ID: <20140123092503.1a7811ef@nehalam.linuxnetplumber.net>
References: <1390469499-31952-1-git-send-email-yangyingliang@huawei.com>
 <1390469499-31952-2-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:41922 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544AbaAWRZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 12:25:10 -0500
Received: by mail-pa0-f42.google.com with SMTP id kl14so2137860pab.1
        for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 09:25:09 -0800 (PST)
In-Reply-To: <1390469499-31952-2-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am not sure how important it is that netem updates to multiple
parameters act as a single transaction. The only failures possible
are out of memory and user configuration error.

I prefer the simplicity of the original code.


> +			/* recover clg and loss_model, in case of
> +			 * q->clg and q->loss_model were modified
> +			 * in get_loss_clg() */

This comment needs to be formatted as:
	/* multiline comment
         * example
         */


 
