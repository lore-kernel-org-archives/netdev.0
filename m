From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] net-gre-gro: Add GRE support to the GRO stack
Date: Sat, 4 Jan 2014 13:52:49 -0800
Message-ID: <20140104135249.7930977c@nehalam.linuxnetplumber.net>
References: <1388756813-10875-1-git-send-email-hkchu@google.com>
	<20140103.205131.1429670011198294911.davem@davemloft.net>
	<CAPshTCgnwX4g1CSgrEK+OwRPjfE5+z2g4YPbHfqhjVND=2xZKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:49911 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753656AbaADVwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 16:52:53 -0500
Received: by mail-pd0-f170.google.com with SMTP id g10so16749085pdj.1
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 13:52:53 -0800 (PST)
In-Reply-To: <CAPshTCgnwX4g1CSgrEK+OwRPjfE5+z2g4YPbHfqhjVND=2xZKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 4 Jan 2014 13:20:28 +0800
Jerry Chu <hkchu@google.com> wrote:

> On Sat, Jan 4, 2014 at 9:51 AM, David Miller <davem@davemloft.net> wrote:
> > From: "H.K. Jerry Chu" <hkchu@google.com>
> > Date: Fri,  3 Jan 2014 05:46:53 -0800
> >
> >> +     if (skb->ip_summed == CHECKSUM_COMPLETE)
> >> +             NAPI_GRO_CB(skb)->csum = csum_sub(NAPI_GRO_CB(skb)->csum,
> >> +                     csum_partial(start, len, 0));
> >
> > The csum_partial() call as argument needs to line up to exactly the
> > first column after the openning parenthesis of the csum_sub()
> > invocation.
> >
> > You must use the appropriate number of TAB then SPACE characters
> > necessary to achieve this.
> >
> > If you indent only using TABS then likely you are doing it wrong :)
> 
> Yes I know but sometimes trying to line up arguments either causes > 80
> column long line, or many shorter but highly indented fragmented lines
> following.
> 
> I've fixed the above case and it worked (stopped at 79th column).
> 
> Jerry

80 columns is recommendation not an absolute requirement.
Also, when things get too long, it often means it could be
made clearer by having a helper function or a temporary variable.
