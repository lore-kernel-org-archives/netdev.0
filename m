From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH] net: rocker: Add basic netdev counters - v2
Date: Fri, 16 Jan 2015 15:41:41 -0800
Message-ID: <CAE4R7bA3QG4LDvVQywDsRuJzJYv4mBq3=OXi2L=qGDfa4a8ykw@mail.gmail.com>
References: <1421443349-77718-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:37385 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502AbbAPXlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 18:41:42 -0500
Received: by mail-we0-f175.google.com with SMTP id k11so22772162wes.6
        for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 15:41:41 -0800 (PST)
In-Reply-To: <1421443349-77718-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 16, 2015 at 1:22 PM, David Ahern <dsahern@gmail.com> wrote:
> Add packet and byte counters for RX and TX paths.
>
> $ ifconfig eth1
> eth1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
>         inet6 fe80::5054:ff:fe12:3501  prefixlen 64  scopeid 0x20<link>
>         ether 52:54:00:12:35:01  txqueuelen 1000  (Ethernet)
>         RX packets 63  bytes 15813 (15.4 KiB)
>         RX errors 1  dropped 0  overruns 0  frame 0
>         TX packets 79  bytes 17991 (17.5 KiB)
>         TX errors 7  dropped 0 overruns 0  carrier 0  collisions 0
>
> Rx / Tx errors tested by injecting faults in qemu's hardware model for Rocker.
>
> v2:
> - moved counter locations to avoid potential use after free per Florian's comment
>
> Signed-off-by: David Ahern <dsahern@gmail.com>
> Cc: Scott Feldman <sfeldma@gmail.com>
> Cc: Jiri Pirko <jiri@resnulli.us>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Thanks David.  I think this is good enough for first pass.  Longer
term, I'd like to see this replaced by stats read from device for each
port.

-scott
