From: Pierre Louis Aublin <pierre-louis.aublin@inria.fr>
Subject: Re: [PATCH 4/4] drivers/net/wireless/mwifiex/scan.c: test the just-initialized
 value
Date: Mon, 22 Aug 2011 16:11:24 +0200
Message-ID: <4E52638C.8080407@inria.fr>
References: <1314021636-11528-4-git-send-email-julia@diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bing Zhao <bzhao@marvell.com>, kernel-janitors@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4-relais-sop.national.inria.fr ([192.134.164.105]:40792
	"EHLO mail4-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752183Ab1HVOL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 10:11:27 -0400
In-Reply-To: <1314021636-11528-4-git-send-email-julia@diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all

On 08/22/2011 04:00 PM, Julia Lawall wrote:
> -	if (!bss_desc) {
> +	if (!beacon_ie) {
>   		dev_err(priv->adapter->dev, " failed to alloc bss_desc\n");
Shouldn't we also modify the error message, from "failed to alloc 
bss_desc" to "failed to alloc beacon_ie" ?

Sincerely
Pierre Louis Aublin
