From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] route: label externally offloaded routes
Date: Sun, 15 Mar 2015 12:41:17 -0700
Message-ID: <20150315124117.57ecf595@urahara>
References: <1425795335-6416-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35788 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751477AbbCOTlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 15:41:16 -0400
Received: by pabyw6 with SMTP id yw6so42803536pab.2
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 12:41:16 -0700 (PDT)
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


All iproute2 commands should be invertable.
If you show something you need to accept that as input.
Please fix that.
