From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v4] ipv6: clean up dev_snmp6 proc entry when we fail
 to initialize inet6_dev
Date: Wed, 04 Nov 2015 10:19:31 -0800
Message-ID: <1446661171.4184.28.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1446658240-31423-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com,
	hannes@stressinduktion.org, cwang@twopensource.com
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33737 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754990AbbKDSTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 13:19:33 -0500
Received: by pabfh17 with SMTP id fh17so59808722pab.0
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2015 10:19:33 -0800 (PST)
In-Reply-To: <1446658240-31423-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-04 at 18:30 +0100, Sabrina Dubroca wrote:
> In ipv6_add_dev, when addrconf_sysctl_register fails, we do not clean up
> the dev_snmp6 entry that we have already registered for this device.
> Call snmp6_unregister_dev in this case.
> 
> Fixes: a317a2f19da7d ("ipv6: fail early when creating netdev named all or default")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
