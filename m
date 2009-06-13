From: Martin Fuzzey <mfuzzey@gmail.com>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver configuration.
Date: Sat, 13 Jun 2009 11:29:50 +0200
Message-ID: <4A33718E.9040600@gmail.com>
References: <4A334E7A.5020805@gmail.com>	<20090613.000729.118500646.davem@davemloft.net>	<4A335A8A.5080907@gmail.com> <20090613.010712.100174619.davem@davemloft.net>
Reply-To: mfuzzey@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, nico@cam.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-1920.google.com ([74.125.78.146]:31718 "EHLO
	ey-out-1920.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753682AbZFMJ3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2009 05:29:51 -0400
Received: by ey-out-1920.google.com with SMTP id 3so297478eyh.26
        for <netdev@vger.kernel.org>; Sat, 13 Jun 2009 02:29:52 -0700 (PDT)
In-Reply-To: <20090613.010712.100174619.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Martin Fuzzey <mfuzzey@gmail.com>
> Date: Sat, 13 Jun 2009 09:51:38 +0200
>   
> The bug is a hardware limitation.
>
> The kernel programs and knows the hardware.
>
> Therefore knowledge of the limitation belongs in the kernel.
>   
Yes indeed and that's why I included the programatic interface to let
the board specific code in the kernel do it in a non intrusive way with
zero driver modifications.
For me the command line method is for the "environment" case you mention
and the programatic interface is for the broken hardware case. The patch
supports both (or just one however you decide to KConfig it) so if you
just want to work around broken hardware you don't have to pay the
overhead of the command line parsing code.
> In no other situation would we say "this aspect of this chip doesn't
> work, so we'll block usage of that in some high level configuration
> framework"
>
> No, we'd always deal with HW problems in the driver itself.
>   
Yes I agree but this isn't about the _chip_ being broken but the _board_
being broken.
IMHO the drivers are supposed to be  chip (or even chip family) specific
not board specific.
The driver in question is fine and doesn't need fixing - even the board
schematic is fine - it's the board layout causing signal corruption at
100MBps...

Martin

