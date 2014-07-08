From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH A 01/12] net: fec: iMX6 FEC does not support half-duplex
 gigabit
Date: Tue, 08 Jul 2014 20:52:00 +0400
Message-ID: <53BC21B0.2020407@cogentembedded.com>
References: <20140707232148.GG21766@n2100.arm.linux.org.uk> <E1X4IF0-0004wh-0e@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:61943 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753269AbaGHQv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 12:51:58 -0400
Received: by mail-la0-f43.google.com with SMTP id e16so4178094lan.2
        for <netdev@vger.kernel.org>; Tue, 08 Jul 2014 09:51:56 -0700 (PDT)
In-Reply-To: <E1X4IF0-0004wh-0e@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 07/08/2014 03:22 AM, Russell King wrote:

> The iMX6 gigabit FEC does not support half-duplex gigabit operation.
> Phys attacked to the FEC may support this, and we currently do nothing

    s/attacked/attached/. Perhaps Dave can fix when applying...

> to disable this feature.  This may result in an invalid configuration.
> Mask out phy support for gigabit half-duplex operation.

> Acked-by: Fugang Duan <B38611@freescale.com>
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

WBR, Sergei
