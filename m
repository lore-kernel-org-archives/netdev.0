From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [iproute PATCH] man: tc-csum.8: Fix example
Date: Fri, 27 Jan 2017 21:49:58 +0100
Message-ID: <20170127204958.uo5ssloejdirohsj@alphalink.fr>
References: <20170127111501.21439-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:49408 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751216AbdA0U4G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 15:56:06 -0500
Content-Disposition: inline
In-Reply-To: <20170127111501.21439-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 27, 2017 at 12:15:01PM +0100, Phil Sutter wrote:
> +# tc filter add dev eth0 prio 1 protocol ip parent ffff: \\
>  	u32 match ip src 192.168.1.100/32 flowid :1 \\
> -	action pedit munge ip dst set 0x12345678 pipe \\
> +	action pedit munge ip dst set 1.2.3.4 pipe \\
> 
Just nitpicking here, but IMHO examples like this should better use IP
addresses reserved for documentation (192.0.2.0/24, 198.51.100.0/24 or
203.0.113.0/24).
