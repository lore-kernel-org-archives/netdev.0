From: "Aviv Greenberg" <avivgnet@gmail.com>
Subject: Re: bnx2_poll panicking kernel
Date: Thu, 10 Jul 2008 12:45:54 +0300
Message-ID: <3000d2e90807100245j74a11b97q7d01f9f0b94dfbe@mail.gmail.com>
References: <4863DA40.9050508@broadcom.com>
	 <20080709164619.GA26098@orion.carnet.hr>
	 <1215622625.5532.43.camel@dell>
	 <20080709.164659.157912631.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, joy@debian.org, billfink@mindspring.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	mirrors@debian.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:61733 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751991AbYGJJp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 05:45:57 -0400
Received: by py-out-1112.google.com with SMTP id p76so1779019pyb.10
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 02:45:55 -0700 (PDT)
In-Reply-To: <20080709.164659.157912631.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 10, 2008 at 02:46, David Miller <davem@davemloft.net> wrote:
>
> So it has to be something else.

What mechanism prevents the clone from happening between
the skb_clone() and skb_split() calls in tcp_fragment?

Maybe there's a path that doesn't take a lock...
