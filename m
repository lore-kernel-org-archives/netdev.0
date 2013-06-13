From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v2] tcp: introduce a per-route knob for quick
 ack
Date: Thu, 13 Jun 2013 16:45:57 +0800
Message-ID: <1371113157.10194.14.camel@cr0>
References: <1371104643-24076-1-git-send-email-amwang@redhat.com>
	 <1371105776.3252.98.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Rick Jones <rick.jones2@hp.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	David Laight <David.Laight@ACULAB.COM>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38332 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758474Ab3FMIq5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jun 2013 04:46:57 -0400
In-Reply-To: <1371105776.3252.98.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-12 at 23:42 -0700, Eric Dumazet wrote:
> On Thu, 2013-06-13 at 14:24 +0800, Cong Wang wrote:
> > diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> > index ec335fa..f840b92 100644
> > --- a/net/ipv4/tcp_output.c
> > +++ b/net/ipv4/tcp_output.c
> > @@ -160,6 +160,7 @@ static void tcp_event_data_sent(struct tcp_sock *tp,
> >  {
> >  	struct inet_connection_sock *icsk = inet_csk(sk);
> >  	const u32 now = tcp_time_stamp;
> > +	const struct dst_entry *dst = __sk_dst_get(sk);
> >  
> 
> 
> Same here : Are you sure dst cannot be NULL ?
> 

No, I missed the check for some reason... Will fix it.

Thanks.
