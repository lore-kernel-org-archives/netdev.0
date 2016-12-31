From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] Introduce a sysctl that modifies the value of
 PROT_SOCK.
Date: Sat, 31 Dec 2016 12:55:05 -0800
Message-ID: <20161231125505.7f0c7dff@xeon-e3>
References: <20161231041111.GD2448@templeofstupid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Krister Johansen <kjlx@templeofstupid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:32945 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753296AbcLaUzN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 31 Dec 2016 15:55:13 -0500
Received: by mail-pg0-f50.google.com with SMTP id g1so150353257pgn.0
        for <netdev@vger.kernel.org>; Sat, 31 Dec 2016 12:55:13 -0800 (PST)
In-Reply-To: <20161231041111.GD2448@templeofstupid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 Dec 2016 20:11:11 -0800
Krister Johansen <kjlx@templeofstupid.com> wrote:

>  
> +config LOWPORT_SYSCTL
> +	bool "Adjust reserved port range via sysctl"
> +	depends on SYSCTL
> +	help
> +	  This allows the administrator to adjust the reserved port range
> +	  using a sysctl.

This looks like a good idea, and makes a lot of sense.

Please don't introduce yet another config option. All distro's will enable it anyway.
Having more config options doesn't help reliability or testability.

Do or do not, please no new config options.
