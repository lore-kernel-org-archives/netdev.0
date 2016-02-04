From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] flowi: add concept of "not_oif"
Date: Wed, 03 Feb 2016 19:44:05 -0800
Message-ID: <1454557445.7627.288.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAHmME9pgwgjKJAFH2=sEEMJauno_rVEzY6JORTQze91Xo5zefw@mail.gmail.com>
	 <1454521595-6721-1-git-send-email-Jason@zx2c4.com>
	 <alpine.LFD.2.11.1602032149170.1802@ja.home.ssi.bg>
	 <CAHmME9qqCZYvuskSQMA0F2d2E+5fHsRk=ydDOV=Nq5D7xemtaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>, Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Ahern <dsa@cumulusnetworks.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33205 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755902AbcBDDoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 22:44:08 -0500
Received: by mail-pf0-f174.google.com with SMTP id w123so29460247pfb.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 19:44:07 -0800 (PST)
In-Reply-To: <CAHmME9qqCZYvuskSQMA0F2d2E+5fHsRk=ydDOV=Nq5D7xemtaw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-02-03 at 22:02 +0100, Jason A. Donenfeld wrote:

> 
> >         I don't know about the particular problems with
> > tunnels but the scripts can use the route metric to order
> > the routes in a table.
> 
> This unfortunately does not cut it with tunnels.

ip rule show

ip route show table 10

I am pretty sure that you could select/change skb mark when packets
traverse the tunnel : The second route lookup can then select a
completely different table.
