From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RESEND][NETFILTER][PATCH] nfqnl_mangle() not requesting enough
 space for bigger reinjected packet.
Date: Tue, 06 May 2008 12:18:33 +0200
Message-ID: <48203079.60001@trash.net>
References: <87abjdvpiq.fsf@natisbad.org> <481647F2.20507@trash.net> <87zlrdtw6q.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87zlrdtw6q.fsf@natisbad.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaud Ebalard wrote:
> BTW, while looking at the code, I noticed the call to skb_copy_expand()
> leads to a complete copy of current sk_buff data to the new sk_buff.
> Those data are then completely rewritten a few lines later. Too bad
> there is no simple way (considering skbuff.h) to prevent the useless
> copy.


Yeah, thats a bit unfortunate. I don't see how we could avoid
this besides allocating a fresh skb and setting up all the meta
data manually though.

