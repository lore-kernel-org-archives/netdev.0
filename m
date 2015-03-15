From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] route: label externally offloaded routes
Date: Sun, 15 Mar 2015 12:39:22 -0700
Message-ID: <20150315123922.4c49291c@urahara>
References: <1425795335-6416-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:35132 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097AbbCOTjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 15:39:20 -0400
Received: by pdbop1 with SMTP id op1so37123302pdb.2
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 12:39:20 -0700 (PDT)
In-Reply-To: <1425795335-6416-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  7 Mar 2015 22:15:35 -0800
sfeldma@gmail.com wrote:

> From: Scott Feldman <sfeldma@gmail.com>
> 
> On ip route print dump, label externally offloaded routes with "external".
> Offloaded routes are flagged with RTNH_F_EXTERNAL, a recent additon to
> net-next.  For example:
> 
> $ ip route
> default via 192.168.0.2 dev eth0
> 11.0.0.0/30 dev swp1  proto kernel  scope link  src 11.0.0.2 external
> 11.0.0.4/30 via 11.0.0.1 dev swp1  proto zebra  metric 20 external
> 11.0.0.8/30 dev swp2  proto kernel  scope link  src 11.0.0.10 external
> 11.0.0.12/30 via 11.0.0.9 dev swp2  proto zebra  metric 20 external
> 12.0.0.2  proto zebra  metric 30 external
>         nexthop via 11.0.0.1  dev swp1 weight 1
>         nexthop via 11.0.0.9  dev swp2 weight 1
> 12.0.0.3 via 11.0.0.1 dev swp1  proto zebra  metric 20 external
> 12.0.0.4 via 11.0.0.9 dev swp2  proto zebra  metric 20 external
> 192.168.0.0/24 dev eth0  proto kernel  scope link  src 192.168.0.15
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Applied to net-next branch of iproute2
