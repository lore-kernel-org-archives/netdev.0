From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: netx-eth: remove unnecessary casting when using
 dev_get_platdata()
Date: Tue, 03 Sep 2013 01:01:03 +0400
Message-ID: <5224FC8F.4080103@cogentembedded.com>
References: <004b01cea774$975b48b0$c611da10$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:57962 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758723Ab3IBVBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 17:01:06 -0400
Received: by mail-lb0-f170.google.com with SMTP id w7so4231899lbi.29
        for <netdev@vger.kernel.org>; Mon, 02 Sep 2013 14:01:04 -0700 (PDT)
In-Reply-To: <004b01cea774$975b48b0$c611da10$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09/02/2013 04:37 AM, Jingoo Han wrote:

> Casting from 'void *' is unnecessary when using dev_get_platdata().

    dev_get_platdata() is irrelevant here. Casting from/to 'void *' to/from 
any pointer type is just automatic.

> Reported-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

WBR, Sergei
