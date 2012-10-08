From: graham.gower@gmail.com
Subject: Re: [PATCH v4] skge: Add DMA mask quirk for Marvell 88E8001 on ASUS P5NSLI motherboard.
Date: Mon, 8 Oct 2012 19:38:06 +1030
Message-ID: <A11ABB5B-9E22-4FD2-9008-BCD33E64B514@gmail.com>
References: <5072760C.7060004@gmail.com> <20121008.030707.864754447318232909.davem@davemloft.net>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:33293 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001Ab2JHJIH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 05:08:07 -0400
Received: by mail-pb0-f46.google.com with SMTP id rr4so3820690pbb.19
        for <netdev@vger.kernel.org>; Mon, 08 Oct 2012 02:08:06 -0700 (PDT)
In-Reply-To: <20121008.030707.864754447318232909.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well its pretty frustrating from my end too.

Fuck it, i dont care enough. I'll just keep patching kernels locally until my hardware expires.

On 08/10/2012, at 5:37 PM, David Miller <davem@davemloft.net> wrote:

> From: Graham Gower <graham.gower@gmail.com>
> Date: Mon, 08 Oct 2012 17:13:24 +1030
> 
>> Marvell 88E8001 on an ASUS P5NSLI motherboard is unable to
>> send/receive
>> packets on a system with >4gb ram unless a 32bit DMA mask is used.
> 
> Please format this ascii text properly.  WHy is there a line
> with just two words surrounded by full nearly 80-column lines?
> 
>> +        .matches = {
>> + DMI_MATCH(DMI_BOARD_VENDOR, "ASUSTeK Computer INC."),
> 
> THis is still formatted incorrectly, it's actually in the file
> not due to your email client.
> 
> Can you indent the thing properly, please?
> 
> This is V4 of this patch, and suffering purely from first order coding
> style and procedural stuff.  As you can imagine, it's very frustrating
> to have to spend this much time getting such simple things taken care
> of.
