From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 3/5] alx: add stats update function
Date: Sat, 4 Jan 2014 14:16:08 -0800
Message-ID: <20140104141608.5d882082@nehalam.linuxnetplumber.net>
References: <1388854031-24142-1-git-send-email-sd@queasysnail.net>
	<1388854031-24142-4-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, bhutchings@solarflare.com,
	johannes@sipsolutions.net, netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33449 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754352AbaADWQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 17:16:12 -0500
Received: by mail-pa0-f51.google.com with SMTP id fa1so17014351pad.24
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 14:16:11 -0800 (PST)
In-Reply-To: <1388854031-24142-4-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  4 Jan 2014 17:47:09 +0100
Sabrina Dubroca <sd@queasysnail.net> wrote:

>  }
> +
> +void __alx_update_hw_stats(struct alx_hw *hw)

Minor NIT:
Why __ prefix? that is usually reserved for functions only
called from one file (or when wrapping an existing API)
