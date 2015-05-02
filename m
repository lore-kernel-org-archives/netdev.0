From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v3 net-next] pktgen: introduce 'rx' mode
Date: Sat, 02 May 2015 12:30:00 +0200
Message-ID: <5544A728.3060304@iogearbox.net>
References: <1430457130-16003-1-git-send-email-ast@plumgrid.com>	<20150502104621.4fede885@redhat.com>	<55449C8D.4020902@iogearbox.net> <20150502115443.2f89736e@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Robert Olsson <robert@herjulf.net>,
	Ben Greear <greearb@candelatech.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42126 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbbEBKaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2015 06:30:14 -0400
In-Reply-To: <20150502115443.2f89736e@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/02/2015 11:54 AM, Jesper Dangaard Brouer wrote:
...
> I personally just don't like the "RX" flag name.
> What about "STACK_RX" or "RX_INJECT"?

I'm not sure if it actually qualifies as a flag from user space
point of view, besides that it's used as an implementation detail.

You could have an option "xmit_mode [rx|tx]" (where obviously tx
is the default), perhaps that makes it clearer that you xmit into
the kernel's rx path.

Cheers,
Daniel
