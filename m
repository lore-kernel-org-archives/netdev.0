From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] sh_eth: fix bitbang memory leak
Date: Wed, 20 Mar 2013 17:38:35 +0400
Message-ID: <5149BBDB.8060604@cogentembedded.com>
References: <201303200240.23975.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:45512 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751688Ab3CTNjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 09:39:24 -0400
Received: by mail-la0-f50.google.com with SMTP id ec20so2908809lab.23
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 06:39:22 -0700 (PDT)
In-Reply-To: <201303200240.23975.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 20-03-2013 3:40, Sergei Shtylyov wrote:

> sh_mdio_init() allocates pointer to 'struct bb_info' but only stores it locally,
> so that sh_mdio_release() can't free it on driver unload.  Add the pointer to
> 'struct bb_info' to 'struct sh_eth_private', so that sh_mdio_init() can save
> 'bitbang' variable for sh_mdio_release() to be able to free it later...

> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

    I was in a bit of hurry and forgot to add:

CC: stable@vger.kernel.org

    Do I need to repost?

WBR, Sergei
