From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2] ip: Simplify executing ip cmd within namespace
Date: Thu, 11 Dec 2014 11:58:21 +0100
Message-ID: <548978CD.80404@6wind.com>
References: <1418252195-2612-1-git-send-email-vadim4j@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:49931 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754388AbaLKK6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 05:58:25 -0500
Received: by mail-wg0-f47.google.com with SMTP id n12so6075445wgh.34
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 02:58:23 -0800 (PST)
In-Reply-To: <1418252195-2612-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/12/2014 23:56, Vadim Kochan a =C3=A9crit :
> From: Vadim Kochan <vadim4j@gmail.com>
>
> Added new '-ns' option to simplify executing following cmd:
>
>      ip netns exec NETNS ip OPTIONS COMMAND OBJECT
>
>      to
>
>      ip -ns NETNS OPTIONS COMMAND OBJECT
>
> e.g.:
>
>      ip -ns vnet0 link add br0 type bridge
>
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
> May be new option should have better name than '-ns' ?
What about 'ip -netns' to be explicit like other options?
user may still use 'ip -n' at the end.


Regards,
Nicolas
