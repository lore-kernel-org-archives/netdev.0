From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH iproute2] route: label externally offloaded routes
Date: Sun, 8 Mar 2015 07:57:44 +0100
Message-ID: <20150308065744.GB1986@nanopsycho.orion>
References: <1425795335-6416-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:40324 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904AbbCHG5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2015 01:57:48 -0500
Received: by wevk48 with SMTP id k48so24212565wev.7
        for <netdev@vger.kernel.org>; Sat, 07 Mar 2015 22:57:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1425795335-6416-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Mar 08, 2015 at 07:15:35AM CET, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>On ip route print dump, label externally offloaded routes with "external".
>Offloaded routes are flagged with RTNH_F_EXTERNAL, a recent additon to
>net-next.  For example:
>
>$ ip route
>default via 192.168.0.2 dev eth0
>11.0.0.0/30 dev swp1  proto kernel  scope link  src 11.0.0.2 external
>11.0.0.4/30 via 11.0.0.1 dev swp1  proto zebra  metric 20 external
>11.0.0.8/30 dev swp2  proto kernel  scope link  src 11.0.0.10 external
>11.0.0.12/30 via 11.0.0.9 dev swp2  proto zebra  metric 20 external
>12.0.0.2  proto zebra  metric 30 external
>        nexthop via 11.0.0.1  dev swp1 weight 1
>        nexthop via 11.0.0.9  dev swp2 weight 1
>12.0.0.3 via 11.0.0.1 dev swp1  proto zebra  metric 20 external
>12.0.0.4 via 11.0.0.9 dev swp2  proto zebra  metric 20 external
>192.168.0.0/24 dev eth0  proto kernel  scope link  src 192.168.0.15
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Reviewed-by: Jiri Pirko <jiri@resnulli.us>
