From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 1/5] send-crc: Add framework to allow sending packets with
 customized CRC.
Date: Tue, 7 Feb 2012 21:33:29 +0100
Message-ID: <CAHXqBFKe+nAGk8gjjOxRSbgtPSPHXcz3_fNjaBaxh48vPvDysQ@mail.gmail.com>
References: <1328644182-7872-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:62899 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756819Ab2BGUdv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 15:33:51 -0500
Received: by ggnh1 with SMTP id h1so3700656ggn.19
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2012 12:33:50 -0800 (PST)
In-Reply-To: <1328644182-7872-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/2/7  <greearb@candelatech.com>:
> From: Ben Greear <greearb@candelatech.com>
>
> This is useful for testing RX handling of frames with bad
> CRCs.
>
> Requires driver support to actually put the packet on the
> wire properly.
[...]

I like this idea. I think that this is not a feature to have in
dev->features to toggle, though. Driver either supports this or not,
so it's better to put it in dev->priv_flags instead. Disabling of FCS
inserting is a per-packet option in the drivers, isn't it?

=46or one problem with toggling: if you create a socket using it and
later turn off the feature, the socket will still send skbs with FCS
appended.

Best Regards,
Micha=C5=82 Miros=C5=82aw
