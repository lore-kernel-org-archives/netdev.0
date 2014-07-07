From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v2 1/8] net-timestamp: explicit SO_TIMESTAMPING
 ancillary data struct
Date: Mon, 7 Jul 2014 20:47:00 +0200
Message-ID: <20140707184700.GA1610@localhost.localdomain>
References: <1404416380-3545-1-git-send-email-willemb@google.com>
 <1404416380-3545-2-git-send-email-willemb@google.com>
 <20140705201851.GE3869@localhost.localdomain>
 <CA+FuTSeSOBUzDLahLBNoW4i-UZe-VOXZr4LgA2bXBfjWxe10Fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	richardcochran@gomail.com,
	Stephen Hemminger <stephen@networkplumber.org>,
	Chad Reese <kreese@caviumnetworks.com>,
	David Daney <david.daney@cavium.com>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:47751 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752025AbaGGSrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 14:47:23 -0400
Received: by mail-wi0-f170.google.com with SMTP id cc10so15447666wib.1
        for <netdev@vger.kernel.org>; Mon, 07 Jul 2014 11:47:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CA+FuTSeSOBUzDLahLBNoW4i-UZe-VOXZr4LgA2bXBfjWxe10Fw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 07, 2014 at 11:34:05AM -0400, Willem de Bruijn wrote:
> 
> The hardware timestamp converted to system time is deprecated? I did
> not know that. Because it is largely unused, or for a more fundamental
> reason?

It is for the fundamental reason that the idea behind it is just plain
wrong. MAC drivers are not the place to put clock servos.

> If so, the documentation could indeed use an explicit comment. The
> definition of skb_shared_hwtstamps.syststamp too. I can write a small
> patch independent of this patchset.

Please do.
 
> Unfortunately, a cursory inspection shows one, octeon. While that user
> exists and generates such timestamps, I think that the above new flag
> should be passed, as well, for API consistency.

Ugh, how the heck did that turd get in? Its not like they bothered to
include the maintainer on CC. That code must go.

Thanks,
Richard
