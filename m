From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH] smsc911x: add fifo byteswap support
Date: Fri, 24 Apr 2009 10:15:03 +0900
Message-ID: <aec7e5c30904231815x79d6f4e8g2e53de1fdeb7a73b@mail.gmail.com>
References: <20090422145553.25073.99410.sendpatchset@rx1.opensource.se>
	 <OFC89C8D8B.9962FD9A-ON802575A0.005335A8-802575A0.00545CBF@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, iwamatsu@nigauri.org, lethal@linux-sh.org,
	netdev@vger.kernel.org, Ian.Saturley@smsc.com
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f166.google.com ([209.85.217.166]:44533 "EHLO
	mail-gx0-f166.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756335AbZDXBPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 21:15:05 -0400
Received: by gxk10 with SMTP id 10so1817678gxk.13
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2009 18:15:03 -0700 (PDT)
In-Reply-To: <OFC89C8D8B.9962FD9A-ON802575A0.005335A8-802575A0.00545CBF@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 23, 2009 at 12:21 AM,  <Steve.Glendinning@smsc.com> wrote:
> Magnus Damm <magnus.damm@gmail.com> wrote on 22/04/2009 15:55:53:
>> This patch adds fifo byteswap support to the smsc911x driver.

> Performance will be suboptimal with this software byteswapping,
> so I think we should also add a comment to stress that this is
> a "last resort" workaround for broken hardware.

Good idea. How about adding the following to the header file right
before the SMSC911X_SWAP_FIFO definition:

/*
 * SMSC911X_SWAP_FIFO:
 * Enables software byte swap for fifo data. Should only be used as a
 * "last resort" in the case of big endian mode on boards with incorrectly
 * routed data bus to older devices such as LAN9118. Newer devices such as
 * LAN9221 handle this in hardware.
 */

Let me know if you want to improve the comment somehow, otherwise I'll
just update the patch and repost a V2.

Cheers,

/ magnus
