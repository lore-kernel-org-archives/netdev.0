From: "avictor.za@gmail.com" <avictor.za@gmail.com>
Subject: Re: [PATCHv2 1/9] at91: provide macb clks with "pclk" and "hclk" name
Date: Wed, 16 Mar 2011 08:53:47 +0200
Message-ID: <AANLkTimwwUQGhncE7Att_9rAXhpT0n61HC4SW8ShSfAm@mail.gmail.com>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
	<1300184096-13937-2-git-send-email-jamie@jamieiles.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	plagnioj@jcrosoft.com, nicolas.ferre@atmel.com
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49544 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751709Ab1CPGxs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2011 02:53:48 -0400
Received: by bwz15 with SMTP id 15so1258070bwz.19
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 23:53:47 -0700 (PDT)
In-Reply-To: <1300184096-13937-2-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

On Tue, Mar 15, 2011 at 12:14 PM, Jamie Iles <jamie@jamieiles.com> wrot=
e:
> The macb driver expects clocks with the names "pclk" and "hclk". =A0W=
e
> currently provide "macb_clk" but to fit in line with other
> architectures (namely AVR32), provide "pclk" and a fake "hclk".

There is no reference to a "pclk" or "hclk" in the AT91 architecture.
So to avoid possible confusion, maybe create two "fake" clocks both
parented to "macb_clk", and add a comment they're only for
compatibility with the AVR32.


Regards,
  Andrew Victor
