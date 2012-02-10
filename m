From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH v2 03/10] e1000e: Support RXFCS feature flag.
Date: Fri, 10 Feb 2012 23:46:57 +0100
Message-ID: <CAHXqBFLjuMRYFgifn_D4W6E1kNqzFeK1Sfe-pMwFhMuwmbsW9w@mail.gmail.com>
References: <1328730885-10941-1-git-send-email-greearb@candelatech.com> <1328730885-10941-4-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:51171 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754518Ab2BJWrS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 17:47:18 -0500
Received: by iacb35 with SMTP id b35so876468iac.19
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2012 14:47:17 -0800 (PST)
In-Reply-To: <1328730885-10941-4-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/2/8  <greearb@candelatech.com>:
> From: Ben Greear <greearb@candelatech.com>
>
> This enables enabling/disabling reception of the Ethernet
> FCS. =A0This can be useful when sniffing packets.
>
> For e1000e, enabling RXFCS can change the default
> behaviour for how the NIC handles CRC. =A0Disabling RXFCS
> will take the NIC back to defaults, which can be configured
> as part of the module options.
[...]

This is not how I would expect the features to behave. Default value
should be set on probe() time, and when you disable RXFCS it should
just get disabled.

Best Regards,
Micha=B3 Miros=B3aw
