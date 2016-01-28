From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ipv4: ipconfig: avoid unused ic_proto_used symbol
Date: Thu, 28 Jan 2016 16:11:44 +0300
Message-ID: <56AA1390.6000503@cogentembedded.com>
References: <1453902853-3424272-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:34373 "EHLO
	mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755186AbcA1NLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 08:11:47 -0500
Received: by mail-lf0-f48.google.com with SMTP id 17so26487085lfz.1
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 05:11:46 -0800 (PST)
In-Reply-To: <1453902853-3424272-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 1/27/2016 4:53 PM, Arnd Bergmann wrote:

> When CONFIG_PROC_FS, CONFIG_IP_PNP_BOOTP, CONFIG_IP_PNP_DHCP and
> CONFIG_IP_PNP_RARP are all disabled, we get a warning about the
> ic_proto_used variable being unused:
>
> net/ipv4/ipconfig.c:146:12: error: 'ic_proto_used' defined but not used [-Werror=unused-variable]
>
> This avoids the warning, but making the definition conditional on

    s/but/by/?

> whether a dynamic IP configuration protocol is configured. If not,
> we know that the value is always zero, so we can optimize away the
> variable and all code that depends on it.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
[...]

MBR, Sergei
