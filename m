From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH] bridge: only provide proxy ARP when CONFIG_INET is enabled
Date: Tue, 13 Jan 2015 19:56:40 -0700
Message-ID: <54B5DAE8.6090907@gmail.com>
References: <56868207.rHBDZL3pbk@wuerfel> <20150113.155740.1237959632603319909.davem@davemloft.net> <54B58AAC.7090001@gmail.com> <4681500.x6CYopasp1@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	netdev@vger.kernel.org, kyeyoonp@codeaurora.org,
	bridge@lists.linux-foundation.org, stephen@networkplumber.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:51569 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202AbbANC4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 21:56:43 -0500
Received: by mail-pd0-f169.google.com with SMTP id z10so7048162pdj.0
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 18:56:42 -0800 (PST)
In-Reply-To: <4681500.x6CYopasp1@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/13/15 2:33 PM, Arnd Bergmann wrote:

> The effect is very similar to my patch (probably same object code), the
> only difference should be that it would add an ugly #ifdef instead of
> the preferred IS_ENABLED() check, so you don't get any compile-time
> coverage of the function.

Indeed. As long as br_do_proxy_arp does not get exported that works the 
same.

David
