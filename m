From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH] net: mv643xx_eth: add missing semicolon
Date: Tue, 04 Jun 2013 08:35:36 +0200
Message-ID: <51AD8AB8.4000709@gmail.com>
References: <4063428.ukZe9BdPSb@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f54.google.com ([209.85.214.54]:50810 "EHLO
	mail-bk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751359Ab3FDGfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 02:35:42 -0400
Received: by mail-bk0-f54.google.com with SMTP id it19so870932bkc.41
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 23:35:40 -0700 (PDT)
In-Reply-To: <4063428.ukZe9BdPSb@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2013 03:11 PM, Arnd Bergmann wrote:
> 76723bca28 "net: mv643xx_eth: add DT parsing support" added a
> dummy mv643xx_eth_shared_of_probe() fallback function with a
> typo.
>
> This adds the missing semicolon so we can build without CONFIG_OF
> again, and changes both dummy functions to the more conventional
> "static inline" syntax, which can avoid potential problems with
> the empty macro.
>
> Signed-off-by: Arnd Bergmann<arnd@arndb.de>
> Cc: Sebastian Hesselbarth<sebastian.hesselbarth@gmail.com>

Arnd,

thanks for cleaning the mess up and apologies for causing this
trouble.

Sebastian
