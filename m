From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH] net: rocker: Add support for retrieving port level statistics
Date: Fri, 30 Jan 2015 14:50:33 -0800
Message-ID: <CAE4R7bDD5YwwRnTVdM8JhbatdD3QzbEZbVJLvRwNXAQG10D6ZQ@mail.gmail.com>
References: <1422590373-22807-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:64350 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763215AbbA3Wuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 17:50:39 -0500
Received: by mail-wg0-f48.google.com with SMTP id x12so29342349wgg.7
        for <netdev@vger.kernel.org>; Fri, 30 Jan 2015 14:50:38 -0800 (PST)
In-Reply-To: <1422590373-22807-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 29, 2015 at 7:59 PM, David Ahern <dsahern@gmail.com> wrote:
> Add support for retrieving port level statistics from device.
> Hook is added for ethtool's stats functionality. For example,
>
> $ ethtool -S eth3
> NIC statistics:
>      rx_packets: 12
>      rx_bytes: 2790
>      rx_dropped: 0
>      rx_errors: 0
>      tx_packets: 8
>      tx_bytes: 728
>      tx_dropped: 0
>      tx_errors: 0
>
> Signed-off-by: David Ahern <dsahern@gmail.com>

Acked-by: Scott Feldman <sfeldma@gmail.com>
