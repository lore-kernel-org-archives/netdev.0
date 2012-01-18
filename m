From: Phil Oester <kernel@linuxace.com>
Subject: Re: [PATCH] net: bpf_jit: fix divide by 0 generation
Date: Wed, 18 Jan 2012 07:57:47 -0800
Message-ID: <20120118155747.GA4991@linuxace.com>
References: <20120118022709.GA4167@linuxace.com>
 <1326867428.2606.39.camel@edumazet-laptop>
 <1326871835.2606.40.camel@edumazet-laptop>
 <1326873533.2606.46.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:54023 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757947Ab2ARP5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 10:57:51 -0500
Received: by ghbg16 with SMTP id g16so3005558ghb.19
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 07:57:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1326873533.2606.46.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 18, 2012 at 08:58:53AM +0100, Eric Dumazet wrote:
> Target of the conditional jump in case a divide by 0 is performed by a
> bpf is wrong.
> 
> Also change the wrong length detection at the end of code generation to
> issue a more explicit message and abort the compilation.
> 
> Reported-by: Phil Oester <kernel@linuxace.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> Please Phil test following fix, thanks !

Got the following output after applying this fix (no panic this time):

proglen=231 != oldproglen=235
bpb_jit_compile fatal error

Filter being used is 'not net a.b.x.112/28 and not net a.b.y.112/28'

Thanks,
Phil
