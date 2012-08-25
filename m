From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] tcp: Wrong timeout for SYN segments
Date: Sat, 25 Aug 2012 11:01:39 +0200
Message-ID: <1345885299.19483.113.camel@edumazet-glaptop>
References: <1345724123.5904.756.camel@edumazet-glaptop>
	 <50362407.9070805@linlab.net> <1345726185.5904.835.camel@edumazet-glaptop>
	 <20120824.134231.41073001349178209.davem@davemloft.net>
	 <20120825084819.GD430@linlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hkjerry.chu@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexander Bergmann <alex@linlab.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120825084819.GD430@linlab.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> From: Alexander Bergmann <alex@linlab.net>
> Date: Fri, 24 Aug 2012 14:09:49 +0200
> Subject: [PATCH 1/1] tcp: Increase timeout for SYN segments
> 
> Commit 9ad7c049 changed the initRTO from 3secs to 1sec in accordance to
> RFC6298 (former RFC2988bis). This reduced the time till the last SYN
> retransmission packet gets sent from 93secs to 31secs.
> 
> RFC1122 is stating that the retransmission should be done for at least 3
> minutes, but this seems to be quite high.
> 
>   "However, the values of R1 and R2 may be different for SYN
>   and data segments.  In particular, R2 for a SYN segment MUST
>   be set large enough to provide retransmission of the segment
>   for at least 3 minutes.  The application can close the
>   connection (i.e., give up on the open attempt) sooner, of
>   course."
> 
> This patch increases the value of TCP_SYN_RETRIES to the value of 6,
> providing a retransmission window of 63secs.
> 
> The comments for SYN and SYNACK retries have also been updated to
> describe the current settings.
> 
> Signed-off-by: Alexander Bergmann <alex@linlab.net>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
