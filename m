From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute2: Fix musl compatibility
Date: Wed, 2 Mar 2016 11:01:35 -0800
Message-ID: <20160302110135.1e21c0ce@xeon-e3>
References: <20160222113447.GA10262@mx.elandsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Loganaden Velvindron <logan@hackers.mu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36361 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754338AbcCBTBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 14:01:23 -0500
Received: by mail-pa0-f45.google.com with SMTP id a9so15882495pat.3
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 11:01:23 -0800 (PST)
In-Reply-To: <20160222113447.GA10262@mx.elandsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Feb 2016 03:34:48 -0800
Loganaden Velvindron <logan@hackers.mu> wrote:

> Don't redefine in6_addr due to including linux/in6.h and also fix
> the case of MAXPATHLEN constant not found.
> 
> (Original patch from VoidLinux)
> 
> Signed-off-by: Loganaden Velvindron <logan@hackers.mu>

I was waiting for others who had more to say on this.
Ok with providing small fixes, but can't really guarantee iproute to
work with other libraries. 
