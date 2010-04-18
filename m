From: John Hughes <john@Calva.COM>
Subject: Re: [PATCH 1/6] X25: Use identifiers for X25 to device interface
Date: Sun, 18 Apr 2010 12:55:05 +0200
Message-ID: <4BCAE509.9000209@Calva.COM>
References: <1271584310.6280.425.camel@ibex>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Hendry <andrew.hendry@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oceanic.CalvaEDI.COM ([89.202.194.168]:41728 "EHLO
	oceanic.CalvaEDI.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756710Ab0DRKzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Apr 2010 06:55:10 -0400
In-Reply-To: <1271584310.6280.425.camel@ibex>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Hendry wrote:
> Use identifiers in x25_device.h instead of magic numbers for X25 layer 3 to device interface.
> Also fixed checkpatch notes on updated code.
> [...]
>  
> -First Byte = 0x00
> +First Byte = 0x00 (X25_IFACE_DATA)
>  [...]
> +
> +enum {
> +	X25_IFACE_DATA,
> +	X25_IFACE_CONNECT,
> +	X25_IFACE_DISCONNECT,
> +	X25_IFACE_PARAMS
> +};
>   
Shouldn't you use explicit values here?

enum {
	X25_IFACE_DATA = 0x00, /* explicit value for ABI stability */
	...


