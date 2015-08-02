From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net] rocker: free netdevice during netdevice removal
Date: Sun, 2 Aug 2015 13:20:49 -0700
Message-ID: <CAE4R7bBDbE9cC0H2J5Q0DsyKd4eyb7y_O4Av8X8jjoMyDP5wgA@mail.gmail.com>
References: <1438536556-13154-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:33159 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298AbbHBUVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2015 16:21:09 -0400
Received: by obdeg2 with SMTP id eg2so85972790obd.0
        for <netdev@vger.kernel.org>; Sun, 02 Aug 2015 13:21:09 -0700 (PDT)
In-Reply-To: <1438536556-13154-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 2, 2015 at 10:29 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Ido Schimmel <idosch@mellanox.com>
>
> When removing a port's netdevice in 'rocker_remove_ports', we should
> also free the allocated 'net_device' structure. Do that by calling
> 'free_netdev' after unregistering it.
>
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> Fixes: 4b8ac9660af ("rocker: introduce rocker switch driver")

Acked-by: Scott Feldman <sfeldma@gmail.com>
