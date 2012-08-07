From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: force dst_default_metrics to const section
Date: Wed, 08 Aug 2012 00:11:07 +0200
Message-ID: <1344377467.28967.199.camel@edumazet-glaptop>
References: <1344355878.28967.113.camel@edumazet-glaptop>
	 <1344370527.2688.61.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120807.145533.2161378343227639185.davem@davemloft.net>
	 <1344377399.28967.198.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:62652 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754808Ab2HGWLP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 18:11:15 -0400
Received: by weyx8 with SMTP id x8so73105wey.19
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2012 15:11:14 -0700 (PDT)
In-Reply-To: <1344377399.28967.198.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-08 at 00:10 +0200, Eric Dumazet wrote:

> # gcc -o try try.c && nm -v try|grep scalar_value
> 00000000004005cc R cscalar_value
> 0000000000601028 B scalar_value
> 000000000060102c B scalar_value_bss
> 0000000000601030 B cscalar_value_bss
> 

Sorry the source was :

const int cscalar_value = 0;
const int cscalar_value_bss;
int scalar_value = 0;
int scalar_value_bss;

main(int argc, char *argv[])
{
return 0;
}
