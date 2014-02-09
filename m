From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] bridge: Unbreak netconsole
Date: Sat, 8 Feb 2014 18:05:11 -0700
Message-ID: <20140208180511.533e1d98@samsung-9>
References: <52F67A4B.9000504@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Neil Horman <nhorman@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Bart Van Assche <bvanassche@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:63860 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbaBIBFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Feb 2014 20:05:18 -0500
Received: by mail-pa0-f51.google.com with SMTP id ld10so4737248pab.10
        for <netdev@vger.kernel.org>; Sat, 08 Feb 2014 17:05:17 -0800 (PST)
In-Reply-To: <52F67A4B.9000504@acm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 08 Feb 2014 19:41:15 +0100
Bart Van Assche <bvanassche@acm.org> wrote:

> Sending netconsole messages over a bridge network interface doesn't
> work anymore since kernel v3.12. Bisecting this led to the patch
> "bridge: cleanup netpoll code". Hence revert that patch (commit
> 93d8bf9fb8f39d6d3e461db60f883d9f81006159).
> 
> Signed-off-by: Bart Van Assche <bvanassche@acm.org>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Jiri Pirko <jiri@resnulli.us>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: <stable@vger.kernel.org> # 3.12
> Reference: https://bugzilla.kernel.org/show_bug.cgi?id=70071

Cong already send an alternative fix for this.
