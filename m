From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net v4] ipv6: clean up dev_snmp6 proc entry when we fail
 to initialize inet6_dev
Date: Wed, 4 Nov 2015 12:47:53 -0800
Message-ID: <CAHA+R7MPrrdKfGHdBN8iLbjw4dZNHg32MSn9vjNZcQL4u0zXZg@mail.gmail.com>
References: <1446658240-31423-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:34904 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965722AbbKDUry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 15:47:54 -0500
Received: by ykek133 with SMTP id k133so95077544yke.2
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2015 12:47:53 -0800 (PST)
In-Reply-To: <1446658240-31423-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 4, 2015 at 9:30 AM, Sabrina Dubroca <sd@queasysnail.net> wrote:
> In ipv6_add_dev, when addrconf_sysctl_register fails, we do not clean up
> the dev_snmp6 entry that we have already registered for this device.
> Call snmp6_unregister_dev in this case.
>
> Fixes: a317a2f19da7d ("ipv6: fail early when creating netdev named all or default")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Reviewed-by: Cong Wang <cwang@twopensource.com>

Thanks!
