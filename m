From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: group DCTCP socket statistics
Date: Tue, 24 Feb 2015 17:38:43 -0800
Message-ID: <20150224173843.48b3799b@urahara>
References: <1424813091-5750-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:32832 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226AbbBYBim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 20:38:42 -0500
Received: by iecar1 with SMTP id ar1so1162643iec.0
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 17:38:41 -0800 (PST)
In-Reply-To: <1424813091-5750-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Feb 2015 22:24:51 +0100
Hagen Paul Pfeifer <hagen@jauu.net> wrote:

> Keep ss output consistent and format DCTCP socket statistics similar to skmen
> and timer where a group of logical values are grouped by brackets. This makes
> parser scripts *and* humans more happy.
> 
> Current output of 'ss -inetm dst :80':
> ESTAB       0      0 192.168.11.14:55511 173.194.66.189:443
>         timer:(keepalive,14sec,0) uid:1000 ino:428768
>         sk:ffff88020ceb5b00 <-> skmem:(r0,rb372480,t0,tb87040,f0,w0,o0,bl0)
>         ts sack wscale:7,7 rto:250 rtt:49.225/20.837 ato:40 mss:1408 cwnd:10
>         ce_state 23 alpha 23 ab_ecn 23 ab_tot 23 send 2.3Mbps
>         lastsnd:121026 lastrcv:121026 lastack:30850 pacing_rate 4.6Mbps
>         retrans:0/2 rcv_rtt:40.416 rcv_space:2920
> 
> New grouped output:
> ESTAB       0      0 192.168.11.14:55511 173.194.66.189:443
>         timer:(keepalive,14sec,0) uid:1000 ino:428768
>         sk:ffff88020ceb5b00 <-> skmem:(r0,rb372480,t0,tb87040,f0,w0,o0,bl0)
>         ts sack wscale:7,7 rto:250 rtt:49.225/20.837 ato:40 mss:1408 cwnd:10
>         dctcp(ce_state:23,alpha:23,ab_ecn:23,ab_tot:23) send 2.3Mbps
>         lastsnd:121026 lastrcv:121026 lastack:30850 pacing_rate 4.6Mbps
>         retrans:0/2 rcv_rtt:40.416 rcv_space:2920
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Acked-by: Daniel Borkmann <dborkman@redhat.com>
> Acked-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>

Applied
