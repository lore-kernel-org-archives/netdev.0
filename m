From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH v5 3/7] tcp: harmonize tcp_vx_rcv header length assumptions
Date: Mon, 15 Feb 2010 07:59:55 -0500
Message-ID: <4B79454B.1030805@gmail.com>
References: <4B793CAA.2030902@gmail.com> <4B793DFC.8070306@gmail.com> <20100215124842.GF21783@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100215124842.GF21783@one.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> On Mon, Feb 15, 2010 at 07:28:44AM -0500, William Allen Simpson wrote:
>> Harmonize tcp_v4_rcv() and tcp_v6_rcv() -- better document tcp doff
>> and header length assumptions, and carefully compare implementations.
> 
> I didn't fully understand that new comment:
> 
> /* nf_reset(skb); in ip6_input.c ip6_input_finish() */
> 
That's part of the harmonization.  IPv4 has a nf_reset() in this code
position.  I asked on the list where IPv6 did the same thing, so that
the difference could be documented.  The information was provided by
Patrick McHardy.  If someday somebody actually finishes merging the
two functions, that's the only actual difference.


> Overall you can add a 
> 
> Reviewed-by: Andi Kleen <andi@firstfloor.org>
> 
Thanks, hopefully as applied.
